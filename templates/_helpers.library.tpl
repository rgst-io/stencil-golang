{{- define "importPath" }}
{{- stencil.Arg "vcs_host" }}
{{- end }}


# Validate arguments
{{- if and (ne (stencil.Arg "vcs") "github") (empty (stencil.Arg "vcs_host")) }}
{{ error "When vcs is not \"github\" vcs_host must be set." }}
{{- end }}

{{- define "ReleaseFormatEnabled" }}
{{ $format := .Data }}

# No formats are enabled if we're a library.
{{ if (stencil.Arg "library") }}
{{ return false }}

# We don't require docker to be set if a Dockerfile exists to ensure
# backwards compat.
{{ else if and (stencil.Exists "Dockerfile") (eq $format "docker") }}
{{ return true }}
{{ else }}

{{ return (has $format (stencil.Arg "release_formats")) }}
{{ end }}
{{- end }}
{{ module.Export "ReleaseFormatEnabled" "caller" }}


{{- define "ReleaseTargetEnabled" }}
{{ $target := .Data }}

# vcs is never actually enabled, despite being the default, unless the
# vcs is NOT github
{{ if and (eq (stencil.Arg "vcs") "github") (eq $target "vcs") }}
	{{ return false }}
{{ else }}
	{{ return (has $target (stencil.Arg "release_targets")) }}
{{ end }}

{{- end }}
{{ module.Export "ReleaseTargetEnabled" "caller" }}
