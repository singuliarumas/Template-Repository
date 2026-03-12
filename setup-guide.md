# Diagnostic KQL Queries
#
# Use these queries in Azure Log Analytics or Azure Workbooks
# to monitor your AI project infrastructure.

## App Service — Request Errors (last 24h)

```kql
AppServiceHTTPLogs
| where TimeGenerated > ago(24h)
| where ScStatus >= 400
| summarize ErrorCount = count() by ScStatus, CsUriStem, bin(TimeGenerated, 1h)
| order by ErrorCount desc
```

## App Service — Slow Requests (>3s)

```kql
AppServiceHTTPLogs
| where TimeGenerated > ago(24h)
| where TimeTaken > 3000
| project TimeGenerated, CsUriStem, CsMethod, ScStatus, TimeTaken
| order by TimeTaken desc
| take 50
```

## App Service — Container Restart Events

```kql
AppServiceConsoleLogs
| where TimeGenerated > ago(7d)
| where ResultDescription has "restart" or ResultDescription has "OOM" or ResultDescription has "exit"
| project TimeGenerated, ResultDescription
| order by TimeGenerated desc
```

## AI Services — Token Usage by Model

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.COGNITIVESERVICES"
| where TimeGenerated > ago(24h)
| extend model = tostring(parse_json(properties_s).modelName)
| extend promptTokens = toint(parse_json(properties_s).promptTokens)
| extend completionTokens = toint(parse_json(properties_s).completionTokens)
| summarize
    TotalPromptTokens = sum(promptTokens),
    TotalCompletionTokens = sum(completionTokens),
    RequestCount = count()
    by model, bin(TimeGenerated, 1h)
```

## AI Services — Error Rate

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.COGNITIVESERVICES"
| where TimeGenerated > ago(24h)
| extend statusCode = toint(httpStatusCode_d)
| summarize
    Total = count(),
    Errors = countif(statusCode >= 400),
    Throttled = countif(statusCode == 429)
    by bin(TimeGenerated, 15m)
| extend ErrorRate = round(100.0 * Errors / Total, 2)
| order by TimeGenerated desc
```

## AI Services — Latency Percentiles

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.COGNITIVESERVICES"
| where TimeGenerated > ago(24h)
| extend duration_ms = todouble(DurationMs)
| summarize
    P50 = percentile(duration_ms, 50),
    P90 = percentile(duration_ms, 90),
    P99 = percentile(duration_ms, 99)
    by bin(TimeGenerated, 15m)
| order by TimeGenerated desc
```

## Key Vault — Access Audit

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where TimeGenerated > ago(7d)
| extend caller = tostring(identity_claim_upn_s)
| summarize AccessCount = count() by OperationName, caller, ResultType
| order by AccessCount desc
```

## Key Vault — Failed Access Attempts

```kql
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.KEYVAULT"
| where TimeGenerated > ago(24h)
| where ResultType != "Success"
| project TimeGenerated, OperationName, ResultType, CallerIPAddress,
    identity_claim_upn_s
| order by TimeGenerated desc
```

## Cross-Resource — Overall Health Dashboard

```kql
Heartbeat
| where TimeGenerated > ago(1h)
| summarize LastHeartbeat = max(TimeGenerated) by Computer, ResourceGroup
| extend Status = iff(LastHeartbeat < ago(10m), "Unhealthy", "Healthy")
```
