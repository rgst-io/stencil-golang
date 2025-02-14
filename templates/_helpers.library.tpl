{{- define "importPath" }}
{{- stencil.Arg "vcs_host" }}
{{- end }}


# Validate arguments
{{- if and (ne (stencil.Arg "vcs") "github") (empty (stencil.Arg "vcs_host")) }}
{{ error "When vcs is not \"github\" vcs_host must be set." }}
{{- end }}
