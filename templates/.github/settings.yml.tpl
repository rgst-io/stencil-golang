{{- if (ne (stencil.Arg "vcs") "github") }}
{{- file.Skip "Not using Github" }}
{{- end }}
# Documentation can be found at:
# https://github.com/repository-settings/app/blob/master/docs/configuration.md
_extends: jaredallard/jaredallard:settings.yml

## <<Stencil::Block(custom)>>
{{ file.Block "custom" }}
## <</Stencil::Block>>
