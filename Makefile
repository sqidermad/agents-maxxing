.PHONY: help install install-cursor install-codex install-claude uninstall doctor pull list dry-run check

help:
	@echo "agents-maxxing — make targets"
	@echo ""
	@echo "  make install         install into Cursor + Codex + Claude Code (symlinks)"
	@echo "  make install-cursor  install into Cursor only"
	@echo "  make install-codex   install into Codex only"
	@echo "  make install-claude  install into Claude Code only"
	@echo "  make uninstall       remove symlinks from all tools"
	@echo "  make doctor          verify install state"
	@echo "  make check           validate skills (frontmatter, names, token table, links)"
	@echo "  make pull            git pull + re-install"
	@echo "  make list            list skills in this repo"
	@echo "  make dry-run         show what install.sh would do"

install:
	@./install.sh

install-cursor:
	@./install.sh --cursor

install-codex:
	@./install.sh --codex

install-claude:
	@./install.sh --claude

uninstall:
	@./uninstall.sh

check:
	@bash scripts/check.sh

dry-run:
	@./install.sh --dry-run

list:
	@echo "skills in this repo:"
	@ls -1 skills/ | sed 's/^/  /'

pull:
	@git pull --ff-only
	@$(MAKE) install

doctor:
	@printf "agents-maxxing doctor\n\n"
	@printf "Repo:   %s\n" "$$(pwd)"
	@printf "Cursor: %s\n" "$$HOME/.cursor/skills-cursor"
	@printf "Codex:  %s\n" "$$HOME/.codex/skills"
	@printf "Claude: %s\n\n" "$$HOME/.claude/skills"
	@for skill_dir in skills/*/; do \
	  name=$$(basename "$$skill_dir"); \
	  printf "%-40s" "$$name"; \
	  for tool_root in "$$HOME/.cursor/skills-cursor" "$$HOME/.codex/skills" "$$HOME/.claude/skills"; do \
	    target="$$tool_root/$$name"; \
	    case "$$tool_root" in \
	      *cursor*) label=cursor ;; \
	      *codex*)  label=codex ;; \
	      *)        label=claude ;; \
	    esac; \
	    if [ -L "$$target" ]; then \
	      link=$$(readlink "$$target"); \
	      expected="$$(pwd)/skills/$$name"; \
	      if [ "$$link" = "$$expected" ]; then \
	        printf " %s:linked" "$$label"; \
	      else \
	        printf " %s:WRONG-LINK" "$$label"; \
	      fi; \
	    elif [ -e "$$target" ]; then \
	      printf " %s:NOT-A-SYMLINK" "$$label"; \
	    else \
	      printf " %s:missing" "$$label"; \
	    fi; \
	  done; \
	  echo; \
	done
