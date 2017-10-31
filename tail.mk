# don't include (generate) .d/.o files if we're cleaning, please.
ifneq ($(MAKECMDGOALS),clean)
# include all the dependencies for the modules found so far via $(N) / $(O)
-include $(patsubst %, $(O)/%.d,$(mods) $(ALLN))
endif
