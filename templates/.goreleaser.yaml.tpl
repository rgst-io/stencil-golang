# yaml-language-server: $schema=https://goreleaser.com/static/schema.json
{{- $org := stencil.Arg "org" }}
version: 2
project_name: {{ .Config.Name }}
report_sizes: true
metadata:
  mod_timestamp: "{{ "{{" }} .CommitTimestamp {{ "}}" }}"
builds:
{{- if stencil.Arg "library" }}
  - skip: true
{{- else }}
{{- range $cmd := (stencil.Arg "commands" | default (list .Config.Name)) }}
  - main: ./cmd/{{ $cmd }}
    id: {{ $cmd }}
    binary: {{ $cmd }}
    flags:
      - -trimpath
    ldflags:
      - -s
      - -w
      {{- $ldflagsBlockName := printf "%s%s" $cmd (title "ldflags") }}
      ## <<Stencil::Block({{ $ldflagsBlockName }})>>
{{ file.Block $ldflagsBlockName }}
      ## <</Stencil::Block>>
    env:
      - CGO_ENABLED=0
    goarch:
{{ stencil.Arg "goarch" | toYaml | indent 6 }}
    goos:
{{ stencil.Arg "goos" | toYaml | indent 6 }}
{{- if and (has "windows" (stencil.Arg "goos")) (has "arm" (stencil.Arg "goarch")) }}
    ignore:
      - goos: windows
        goarch: arm
{{- end }}
    mod_timestamp: "{{ "{{" }} .CommitTimestamp {{ "}}" }}"
{{- end }}
{{- end }}
{{- if not (module.Call "ReleaseFormatEnabled" "binaries") }}
archives:
- formats:
  - none
{{- end }}
{{- if (module.Call "ReleaseFormatEnabled" "docker") }}
dockers_v2:
  - images:
    {{- if module.Call "ReleaseTargetEnabled" "vcs" }}
    - {{ stencil.Arg "vcs_host" }}/{{ $org }}/{{ "{{ .ProjectName }}" }}
    {{- end }}
    - ghcr.io/{{ $org }}/{{ "{{ .ProjectName }}" }}
    labels:
      "org.opencontainers.image.title": {{ "{{ .ProjectName }}" | quote }}
      "org.opencontainers.image.description": {{ "{{ .ProjectName }}" | quote }}
      "org.opencontainers.image.source": {{ "{{ .GitURL }}" | quote }}
      "org.opencontainers.image.version": {{ "{{ .Version }}" | quote }}
      "org.opencontainers.image.created": {{ "{{ .Date }}" | quote }}
      "org.opencontainers.image.revision": {{ "{{ .FullCommit }}" | quote }}
      "org.opencontainers.image.licenses": {{ stencil.Arg "license" | quote }}
    platforms:
{{- range $arch := (stencil.Arg "goarch") }}
    - linux/{{ $arch }}
{{- end }}
{{- end }}
checksum:
  name_template: "checksums.txt"
snapshot:
  version_template: "{{ "{{ incpatch .Version }}" }}-next"
changelog:
  use: git
release:
  {{- if (eq (stencil.Arg "vcs") "forgejo") }}
  gitea:
    owner: {{ $org }}
    name: {{ .Config.Name }}

  {{- end }}
  prerelease: "auto"
  footer: |-
    **Full Changelog**: https://{{ stencil.Arg "vcs_host" }}/{{ $org }}/{{ .Config.Name }}/compare/{{ "{{ .PreviousTag }}" }}...{{ "{{ .Tag }}" }}

{{- if (eq (stencil.Arg "vcs") "forgejo") }}

gitea_urls:
  api: https://{{ stencil.Arg "vcs_host" }}/api/v1
  download: https://{{ stencil.Arg "vcs_host" }}
{{- end }}

## <<Stencil::Block(extraReleaseOpts)>>
{{ file.Block "extraReleaseOpts" }}
## <</Stencil::Block>>
