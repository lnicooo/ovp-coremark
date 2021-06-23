ifndef IMPERAS_HOME
  IMPERAS_ERROR := $(error "IMPERAS_HOME not defined, please setup Imperas/OVP environment")
endif
IMPERAS_HOME := $(shell getpath.exe "$(IMPERAS_HOME)")
include $(IMPERAS_HOME)/bin/Makefile.include

CROSS?=RISCV32I
-include $(IMPERAS_HOME)/lib/$(IMPERAS_ARCH)/CrossCompiler/$(CROSS).makefile.include
ifeq ($($(CROSS)_CC),)
    IMPERAS_ERROR := $(error "Please install the toolchain to support $(CROSS) ")
endif

OPTIMISATION?=-O0

PROGNAME?=coremark

SRC_FILES?= softmul.c \
	core_list_join.c \
	core_matrix.c \
	core_portme.c \
	core_state.c \
	core_util.c \
	core_main.c

ELF = $(addsuffix .$(CROSS).elf, $(PROGNAME))
#OBJ = $(patsubst %.s, %.o, $(patsubst %.c, %.o, $(SRC_FILES)))
OBJ = $(patsubst %.c, %.$(CROSS).o, $(SRC_FILES))
#OBJ = $($(patsubst %.s, %.o, $(ASM)) $(patsubst %.c, %.o, $(SRC)))

all: $(ELF)

%.$(CROSS).elf: $(OBJ)
	$(V)  echo "# Linking $@"
	$(V)  $(IMPERAS_LINK) -o $@ $+ $(IMPERAS_LDFLAGS) -lm

%.$(CROSS).o: %.c
	$(V)  echo "# Compiling $<"
	$(V)  $(IMPERAS_CC) -g -O2 -c -o $@ $<

%.o: %.s
	$(V)  echo "# Assembling $<"
	$(V)  $(IMPERAS_AS) -o $@ $<


clean:
	-rm -f *.elf *.o 

realclean: clean
	-rm -f *.log
