# PSScriptAnalyzer settings for bootstrap.ps1
# Usage: Invoke-ScriptAnalyzer -Path tools/bootstrap.ps1 -Settings tools/PSScriptAnalyzerSettings.psd1
@{
    ExcludeRules = @(
        # Interactive TUI rendering requires direct console output and cursor control.
        'PSAvoidUsingWriteHost',
        # This is an interactive bootstrap script, not an advanced cmdlet module.
        'PSUseShouldProcessForStateChangingFunctions',
        # Positional arguments keep this script concise and readable.
        'PSAvoidUsingPositionalParameters',
        # Function names are kept stable for compatibility in this script.
        'PSUseSingularNouns',
        # Best-effort fallback paths intentionally ignore non-fatal probe errors.
        'PSAvoidUsingEmptyCatchBlock',
        # Some compatibility and future-use parameters are intentionally retained.
        'PSReviewUnusedParameter'
    )
}
