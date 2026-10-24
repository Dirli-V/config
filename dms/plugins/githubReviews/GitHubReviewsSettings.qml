import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "githubReviews"

    StyledText {
        width: parent.width
        text: "GitHub Reviews"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Shows open pull requests that request your review. Requires authenticated GitHub CLI (gh)."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    ToggleSetting {
        id: noTriggerToggle
        settingKey: "noTrigger"
        label: "Always Active"
        description: value ? "Review PRs appear in normal search" : "Activate with a trigger prefix"
        defaultValue: false
        onValueChanged: {
            if (value)
                root.saveValue("trigger", "");
            else
                root.saveValue("trigger", triggerSetting.value || "r ");
        }
    }

    StringSetting {
        id: triggerSetting
        visible: !noTriggerToggle.value
        settingKey: "trigger"
        label: "Trigger"
        description: "Prefix to open review requests. Prefer \"r \" (r + space) so words like redis do not match."
        placeholder: "r "
        defaultValue: "r "
    }

    SelectionSetting {
        settingKey: "maxResults"
        label: "Max results"
        description: "Maximum PRs to fetch from GitHub search"
        defaultValue: "50"
        options: [
            { label: "10", value: "10" },
            { label: "25", value: "25" },
            { label: "50", value: "50" },
            { label: "100", value: "100" }
        ]
    }

    SelectionSetting {
        settingKey: "cacheTtlSec"
        label: "Cache duration"
        description: "Reuse the last fetch for this long before refreshing automatically"
        defaultValue: "60"
        options: [
            { label: "15 seconds", value: "15" },
            { label: "30 seconds", value: "30" },
            { label: "1 minute", value: "60" },
            { label: "5 minutes", value: "300" }
        ]
    }
}
