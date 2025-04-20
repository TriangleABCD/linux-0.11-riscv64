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
SRC_DIR:= $(TOP_DIR)/src/kernel
BUILD_DIR:= $(TOP_DIR)/build

SRC:= $(shell find $(SRC_DIR) -name "*.s")
SRC+= $(shell find $(SRC_DIR) -name "*.c")

OBJS:= $(patsubst $(SRC_DIR)/%.c, $(BUILD_DIR)/%.o, $(SRC))
OBJS:= $(patsubst $(SRC_DIR)/%.s, $(BUILD_DIR)/%.o, $(OBJS))

CFLAGS:= --freestanding -I$(SRC_DIR)/bsp
# 项目名
NAME:= kernel.elf

################################################################

$(NAME): $(OBJS)
	@mkdir -p $(dir $@)
	$(LD) $^ -o $@ --entry=_start -Ttext=0x80000000

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

qemu: $(NAME)
	$(QEMU) $(QEMU_FLAGS) -kernel $(NAME)

debug:
	@echo $(OBJS)

clean:
	rm -rf $(BUILD_DIR)	$(NAME)

.PHONY: qemu clean debug
