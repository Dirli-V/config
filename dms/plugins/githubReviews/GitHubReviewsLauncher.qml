import QtQuick
import Quickshell
import qs.Common
import qs.Services

QtObject {
    id: root

    property var pluginService: null
    property string pluginId: "githubReviews"
    property string trigger: "r "

    signal itemsChanged()

    property var pullRequests: []
    property string status: "idle" // idle | loading | ready | error
    property string errorMessage: ""
    property double lastFetchedAt: 0
    property int cacheTtlMs: 60000
    property int maxResults: 50

    Component.onCompleted: {
        if (!pluginService)
            return;

        trigger = pluginService.loadPluginData(pluginId, "trigger", "r ");
        _reloadSettings();
        refresh(false);
    }

    function _reloadSettings() {
        if (!pluginService)
            return;

        const ttlSec = parseInt(pluginService.loadPluginData(pluginId, "cacheTtlSec", "60"), 10);
        cacheTtlMs = (isNaN(ttlSec) ? 60 : ttlSec) * 1000;

        const max = parseInt(pluginService.loadPluginData(pluginId, "maxResults", "50"), 10);
        maxResults = isNaN(max) ? 50 : max;
    }

    function getItems(query) {
        refresh(false);

        const q = (query || "").trim().toLowerCase();
        const items = [];

        if (status === "loading" && pullRequests.length === 0) {
            items.push({
                name: "Loading review requests…",
                icon: "material:hourglass_empty",
                comment: "Fetching open PRs from GitHub",
                action: "noop:",
                categories: ["Reviews"]
            });
            return items;
        }

        if (status === "error" && pullRequests.length === 0) {
            items.push({
                name: "Failed to load review requests",
                icon: "material:error",
                comment: errorMessage || "Unknown error",
                action: "refresh:",
                categories: ["Reviews"]
            });
            items.push({
                name: "Retry",
                icon: "material:refresh",
                comment: "Fetch PRs again",
                action: "refresh:",
                categories: ["Reviews"]
            });
            return items;
        }

        const filtered = q.length === 0 ? pullRequests : pullRequests.filter(pr => {
            return pr.title.toLowerCase().includes(q)
                || pr.repo.toLowerCase().includes(q)
                || pr.author.toLowerCase().includes(q)
                || String(pr.number).includes(q);
        });

        for (let i = 0; i < filtered.length; i++) {
            const pr = filtered[i];
            items.push({
                name: pr.repo + " #" + pr.number + " — " + pr.title,
                icon: "material:merge",
                comment: "@" + pr.author + (pr.updatedAt ? " · updated " + _formatAge(pr.updatedAt) : ""),
                action: "open:" + pr.url,
                categories: ["Reviews"],
                keywords: [pr.repo, pr.author, String(pr.number), pr.title],
                url: pr.url
            });
        }

        if (filtered.length === 0 && status === "ready") {
            items.push({
                name: q.length > 0 ? "No matching review requests" : "No PRs awaiting your review",
                icon: "material:task_alt",
                comment: q.length > 0 ? "Try a different search" : "You're all caught up",
                action: "noop:",
                categories: ["Reviews"]
            });
        }

        items.push({
            name: "Refresh",
            icon: "material:refresh",
            comment: lastFetchedAt > 0 ? "Last fetched " + _formatAge(lastFetchedAt) : "Fetch from GitHub now",
            action: "refresh:",
            categories: ["Reviews"]
        });

        return items;
    }

    function executeItem(item) {
        if (!item?.action)
            return;

        const colonIdx = item.action.indexOf(":");
        const actionType = item.action.substring(0, colonIdx);
        const actionData = item.action.substring(colonIdx + 1);

        switch (actionType) {
        case "open":
            Qt.openUrlExternally(actionData);
            break;
        case "refresh":
            refresh(true);
            break;
        case "noop":
            break;
        default:
            console.warn("GitHubReviews: unknown action", actionType);
        }
    }

    function getContextMenuActions(item) {
        if (!item?.url)
            return [];

        return [
            {
                icon: "open_in_new",
                text: "Open in browser",
                closeLauncher: true,
                action: () => Qt.openUrlExternally(item.url)
            },
            {
                icon: "content_copy",
                text: "Copy URL",
                action: () => {
                    Quickshell.execDetached(["dms", "cl", "copy", item.url]);
                    if (typeof ToastService !== "undefined")
                        ToastService.showInfo("GitHub Reviews", "Copied PR URL");
                }
            }
        ];
    }

    function refresh(force) {
        _reloadSettings();

        const now = Date.now();
        if (!force && status === "loading")
            return;
        if (!force && pullRequests.length > 0 && (now - lastFetchedAt) < cacheTtlMs)
            return;

        status = "loading";
        errorMessage = "";
        _notify();

        const limit = Math.max(1, Math.min(100, maxResults || 50));
        Proc.runCommand(
            "githubReviews.fetch",
            [
                "gh", "search", "prs",
                "--review-requested=@me",
                "--state=open",
                "--limit", String(limit),
                "--json", "number,title,url,repository,author,updatedAt"
            ],
            (stdout, exitCode) => {
                if (exitCode !== 0) {
                    status = "error";
                    errorMessage = _formatGhError(stdout, exitCode);
                    pullRequests = [];
                    _notify();
                    return;
                }

                try {
                    const raw = JSON.parse(stdout || "[]");
                    pullRequests = raw.map(pr => ({
                        number: pr.number,
                        title: pr.title || "",
                        url: pr.url || "",
                        repo: typeof pr.repository === "string"
                            ? pr.repository
                            : ((pr.repository && (pr.repository.nameWithOwner || pr.repository.name)) || "unknown"),
                        author: typeof pr.author === "string"
                            ? pr.author
                            : ((pr.author && (pr.author.login || pr.author.name)) || "unknown"),
                        updatedAt: pr.updatedAt ? Date.parse(pr.updatedAt) : 0
                    }));
                    status = "ready";
                    lastFetchedAt = Date.now();
                    errorMessage = "";
                } catch (e) {
                    status = "error";
                    errorMessage = "Failed to parse GitHub response";
                    pullRequests = [];
                    console.warn("GitHubReviews: parse error", e);
                }

                _notify();
            },
            force ? 0 : 150,
            20000,
            root
        );
    }

    function _notify() {
        itemsChanged();
        if (pluginService)
            pluginService.requestLauncherUpdate(pluginId);
    }

    function _formatGhError(stdout, exitCode) {
        const text = (stdout || "").trim();
        if (exitCode === 127 || text.toLowerCase().includes("not found"))
            return "gh CLI not found — install GitHub CLI";
        if (text.toLowerCase().includes("auth") || text.toLowerCase().includes("login"))
            return "Not authenticated — run: gh auth login";
        if (exitCode === 124)
            return "Timed out talking to GitHub";
        if (text.length > 0)
            return text.split("\n")[0].slice(0, 120);
        return "gh exited with code " + exitCode;
    }

    function _formatAge(timestamp) {
        if (!timestamp)
            return "";
        const seconds = Math.floor((Date.now() - timestamp) / 1000);
        if (seconds < 60)
            return "just now";
        const minutes = Math.floor(seconds / 60);
        if (minutes < 60)
            return minutes + "m ago";
        const hours = Math.floor(minutes / 60);
        if (hours < 24)
            return hours + "h ago";
        const days = Math.floor(hours / 24);
        return days + "d ago";
    }

    onTriggerChanged: {
        if (pluginService)
            pluginService.savePluginData(pluginId, "trigger", trigger);
    }
}
