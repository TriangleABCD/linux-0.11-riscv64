# 目录变量
TOP_DIR:= $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))
CUR_DIR:= $(CURDIR)

# 交叉编译工具链
CROSS_COMPILE:= riscv64-linux-gnu-
CC:= $(CROSS_COMPILE)gcc
LD:= $(CROSS_COMPILE)ld

# QEMU 选项
QEMU:= qemu-system-riscv64
CPUS:= 4
MEM:= 512m
QEMU_FLAGS:= -bios none -smp $(CPUS) -nographic -M virt -m $(MEM)

# 源文件和目标文件
SRC_DIR:= $(TOP_DIR)/src
BUILD_DIR:= $(TOP_DIR)/build
OUT_DIR:= $(TOP_DIR)/out

SRC:= $(shell find $(SRC_DIR) -name "*.s")
SRC+= $(shell find $(SRC_DIR) -name "*.c")

OBJS:= $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRC))
OBJS:= $(patsubst $(SRC_DIR)/%.s, $(BUILD_DIR)/%.o, $(OBJS))

INCLUDE_FLAG:= -I$(TOP_DIR)/src/include
INCLUDE_FLAG+= -I$(TOP_DIR)/src/arch/riscv64/driver

CFLAGS:= --freestanding $(INCLUDE_FLAG)

NAME:= kernel.elf

################################################################

$(NAME): $(OBJS)
	@mkdir -p $(dir $@)
	@mkdir -p $(OUT_DIR)
	$(LD) $^ -o $(OUT_DIR)/$@ --entry=_start -Ttext=0x80000000

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

qemu: $(NAME)
	$(QEMU) $(QEMU_FLAGS) -kernel $(OUT_DIR)/$(NAME)

debug:
	@echo $(OBJS)

clean:
	rm -rf $(BUILD_DIR)	$(OUT_DIR)

.PHONY: qemu clean debug
