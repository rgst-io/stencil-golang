Copyright (c) {{ dateInZone "2006" (now) "UTC" }} The {{ .Config.Name }} Authors

This source code is protected under international copyright law.  All rights
reserved and protected by the copyright holders.

{{- if not (eq (stencil.Arg "license") "Proprietary") }}
{{- file.Skip "Not proprietary" }}
{{- end }}
{{- $_ := file.SetPath "LICENSE" }}
{{- $_ := file.Static }}