name: release

on:
  # Only run when triggered through the Github UI or API.
  workflow_dispatch:
    inputs:
      rc:
        description: "Build a release candidate instead of a stable release"
        required: false
        default: false
        type: boolean
      version:
        description: "Set a specific version to release, defaults to automatic versioning based on conventional commits"
        required: false
        default: ""
        type: string

permissions:
  contents: write
  packages: write
  issues: write
  # Used by attestations in the release workflow.
  id-token: write
  attestations: write

concurrency:
  group: {{ "${{" }} github.workflow {{ "}}" }}-{{ "${{" }} github.head_ref {{ "}}" }}
  cancel-in-progress: true

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      ## <<Stencil::Block(releaseSetup)>>
{{ file.Block "releaseSetup" }}
      ## <</Stencil::Block>>
      {{- /* renovate: datasource=github-tags packageName=actions/checkout */}}
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          fetch-tags: true
			{{- if (eq (stencil.Arg "vcs") "github") -}}
			{{- /* renovate: datasource=github-tags packageName=jdx/mise-action */}}
      - uses: jdx/mise-action@v2
			{{- else if (eq (stencil.Arg "vcs") "forgejo") }}
      - uses: https://git.rgst.io/rgst-io/mise-action@v2
			{{- end }}
        with:
          experimental: true
				{{- if (eq (stencil.Arg "vcs") "forgejo") }}
          ## <<Stencil::Block(forgejoGithubToken)>>
          github_token: {{ (file.Block "forgejoGithubToken" | default "github_token: ''" | fromYaml).github_token | default "${{ github.token }}" }}
          ## <</Stencil::Block>>
				{{- else }}
        env:
          GH_TOKEN: {{ "${{" }} github.token {{ "}}" }}
        {{- end }}
      - name: Get Go directories
        id: go
        run: |
          echo "cache_dir=$(go env GOCACHE)" >> "$GITHUB_OUTPUT"
          echo "mod_cache_dir=$(go env GOMODCACHE)" >> "$GITHUB_OUTPUT"
      {{- /* renovate: datasource=github-tags packageName=actions/cache */}}
      - uses: actions/cache@v4
        with:
          path: {{ "${{" }} steps.go.outputs.cache_dir {{ "}}" }}
          key: {{ "${{" }} github.workflow {{ "}}" }}-{{ "${{" }} runner.os {{ "}}" }}-go-build-cache-{{ "${{" }} hashFiles('**/go.sum') {{ "}}" }}
      {{- /* renovate: datasource=github-tags packageName=actions/cache */}}
      - uses: actions/cache@v4
        with:
          path: {{ "${{" }} steps.go.outputs.mod_cache_dir {{ "}}" }}
          key: {{ "${{" }} github.workflow {{ "}}" }}-{{ "${{" }} runner.os {{ "}}" }}-go-mod-cache-{{ "${{" }} hashFiles('go.sum') {{ "}}" }}
      - name: Retrieve goreleaser version
        run: |-
          echo "version=$(mise current goreleaser)" >> "$GITHUB_OUTPUT"
        id: goreleaser
      - name: Login to GitHub Container Registry
        {{- /* renovate: datasource=github-tags packageName=docker/login-action */}}
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: {{ "${{" }} github.actor {{ "}}" }}
          password: {{ "${{" }} secrets.GITHUB_TOKEN {{ "}}" }}
      - name: Set up git user
        {{- /* renovate: datasource=github-tags packageName=fregante/setup-git-user */}}
        uses: fregante/setup-git-user@v2
      - name: Download syft (SBOM)
        {{- /* renovate: datasource=github-tags packageName=anchore/sbom-action */}}
        uses: anchore/sbom-action/download-syft@v0.20.0

      # Bumping logic
      - name: Get next version
        id: next_version
        env:
          BUILD_RC: {{ "${{"}} github.event.inputs.rc {{ "}}" }}
          VERSION_OVERRIDE: {{ "${{"}} github.event.inputs.version {{ "}}" }}
        run: |-
          echo "version=$(./.github/scripts/get-next-version.sh)" >> "$GITHUB_OUTPUT"
      - name: Create Tag
        run: |-
          git tag -a "{{ "${{ steps.next_version.outputs.version }}" }}" -m "Release {{ "${{ steps.next_version.outputs.version }}" }}"
      - name: Generate CHANGELOG
        run: |-
          mise run changelog-release
      - name: Create release artifacts and Github Release
        {{- /* renovate: datasource=github-tags packageName=goreleaser/goreleaser-action */}}
        uses: goreleaser/goreleaser-action@v6
        with:
          distribution: goreleaser
          version: v{{ "${{" }} steps.goreleaser.outputs.version {{ "}}" }}
          args: release --release-notes CHANGELOG.md --clean
        env:
          GITHUB_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}
          ## <<Stencil::Block(goreleaseEnvVars)>>
{{ file.Block "goreleaseEnvVars" }}
          ## <</Stencil::Block>>
{{- if not (stencil.Arg "library") }}
      {{- /* renovate: datasource=github-tags packageName=actions/attest-build-provenance */}}
      - uses: actions/attest-build-provenance@v2
        with:
          # We attest all generated _archives_ because those are what we
          # upload to Github Releases.
          subject-path: dist/{{ .Config.Name }}_*.*, dist/checksums.txt
{{- end }}
