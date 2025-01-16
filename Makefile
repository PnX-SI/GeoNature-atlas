-include Makefile.perso.mk

###########################
#          colors         #
###########################
PRINT_COLOR = printf
COLOR_SUCCESS = \033[1;32m
COLOR_DEBUG = \033[36m
COLOR_RESET = \033[0m

###########################
#        Variables        #
###########################

DIR_BIN = venv/bin/

###########################
#        Run project      #
###########################

.PHONY: serve-dev
serve-dev:
	$(call display_cmd, Start dev server)
	$(DIR_BIN)flask --app ./atlas/app run --debug -h 0.0.0.0

###########################
#   Manage translations   #
###########################

.PHONY: messages
messages:
	$(call display_cmd, Extract translations)
	$(DIR_BIN)pybabel extract -F atlas/babel.cfg -o atlas/messages.pot atlas
	$(DIR_BIN)pybabel update -i atlas/messages.pot -d atlas/translations

.PHONY: compile_messages
compile_messages:
	$(call display_cmd, Apply translations)
	$(DIR_BIN)pybabel compile -d atlas/translations

define display_cmd
	@$(PRINT_COLOR) "\n$(COLOR_SUCCESS) ########################## $(COLOR_RESET)\n"
	@$(PRINT_COLOR) "$(COLOR_SUCCESS) ### $(1) $(COLOR_RESET)\n"
	@$(PRINT_COLOR) "$(COLOR_SUCCESS) ########################## $(COLOR_RESET)\n\n"
endef
