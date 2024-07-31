{{- if eq (stencil.Arg "license") "Proprietary" }}
Copyright (c) {{ dateInZone "2006" (now) "UTC" }} The {{ .Config.Name }} Authors

This source code is protected under international copyright law.  All rights
reserved and protected by the copyright holders.
{{- else }}
{{- /* Otherwise, fetch from Github */}}
{{- $license := extensions.Call "github.com/rgst-io/stencil-golang.GetLicense" (stencil.Arg "license") }}
{{ $license.body }}
{{- end }}
