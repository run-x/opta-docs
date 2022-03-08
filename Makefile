HUGO_VERSION      = $(shell grep ^HUGO_VERSION netlify.toml | tail -n 1 | cut -d '=' -f 2 | tr -d " \"\n")

module-check: ## Check if all of the required submodules are correctly initialized.
	@git submodule status --recursive | awk '/^[+-]/ {err = 1; printf "\033[31mWARNING\033[0m Submodule not initialized: \033[34m%s\033[0m\n",$$2} END { if (err != 0) print "You need to run \033[32mmake module-init\033[0m to initialize missing modules first"; exit err }' 1>&2

module-init: ## Initialize required submodules.
	@echo "Initializing submodules..." 1>&2
	@git submodule update --init --recursive --depth 1

build: module-check ## Build site with non-production settings and put deliverables in ./public
	hugo --minify --environment development

build-preview: module-check ## Build site with drafts and future posts enabled
	hugo --buildDrafts --buildFuture --environment preview

deploy-preview: ## Deploy preview site via netlify
	hugo --enableGitInfo --buildFuture --environment preview -b $(DEPLOY_PRIME_URL)

non-production-build: module-check ## Build the non-production site, which adds noindex headers to prevent indexing
	hugo --enableGitInfo --environment nonprod