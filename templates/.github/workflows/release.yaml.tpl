name: release

on:
  # Only run when triggered through the Github UI or API.
  workflow_dispatch: {}

permissions:
  contents: write
  packages: write
  issues: write

concurrency:
  group: {{ .Config.Name }}-release-{{ "${{" }} github.head_ref {{ "}}" }}
  cancel-in-progress: true

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      {{- /* renovate: datasource=github-tags packageName=actions/checkout */}}
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          fetch-tags: true
      {{- /* renovate: datasource=github-tags packageName=jdx/mise-action */}}
      - uses: jdx/mise-action@v2.0.4
        with:
          experimental: true
        env:
          GH_TOKEN: {{ "${{" }} github.token {{ "}}" }}
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
      - uses: fregante/setup-git-user@v2

      # Bumping logic
      - name: Get next version
        id: next_version
        {{- /* renovate: datasource=github-tags packageName=thenativeweb/get-next-version */}}
        uses: thenativeweb/get-next-version@main
        with:
          prefix: "v" # optional, defaults to ''
      - name: Wait for manual approval
        {{- /* renovate: datasource=github-tags packageName=trstringer/manual-approval */}}
        uses: trstringer/manual-approval@v1
        with:
          secret: {{ "${{ secrets.GITHUB_TOKEN }}" }}
          approvers: "jaredallard"
          issue-title: "Release {{ "${{ steps.next_version.outputs.version }}" }}"
      - name: Create Tag
        run: |-
          git tag -a "{{ "${{ steps.next_version.outputs.version }}" }}" -m "Release {{ "${{ steps.next_version.outputs.version }}" }}"
      - name: Create release artifacts and Github Release
        {{- /* renovate: datasource=github-tags packageName=goreleaser/goreleaser-action */}}
        uses: goreleaser/goreleaser-action@v5
        with:
          distribution: goreleaser
          version: v{{ "${{" }} steps.goreleaser.outputs.version {{ "}}" }}
          args: release --clean
        env:
          GITHUB_TOKEN: {{ "${{ secrets.GITHUB_TOKEN }}" }}