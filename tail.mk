# don't include (generate) .d/.o files if we're cleaning, please.
ifeq ($(CLEANING),)
# include all the dependencies for the modules found so far via $(N) / $(O)
-include $(patsubst %, $(O)/%.d,$(mods) $(ALLN))
endif

$(eval $(POPVARS))
