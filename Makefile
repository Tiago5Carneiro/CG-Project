UNAME_S := $(shell uname -s)

CXX = g++ 

# Set compiler flags with warnings enabled and force colored output
CXXFLAGS := -std=c++11 -g -fsanitize=address -O3 -I$(PWD)/src -Wall -Wextra -fdiagnostics-color=always

# Create a warnings file
WARNINGS_FILE := .build_warnings.tmp

# OS-specific flags
ifeq ($(UNAME_S), Darwin) # macOS
    CXXFLAGS += -DGL_SILENCE_DEPRECATION
    LDFLAGS = -fsanitize=address -framework OpenGL -framework GLUT -lIL -lILU -lILUT
else ifeq ($(UNAME_S), Linux) # Linux
    LDFLAGS = -fsanitize=address -lGL -lGLU -lglut -lGLEW -lIL -lILU -lILUT
else ifeq ($(findstring MINGW,$(UNAME_S)),MINGW) # Windows MinGW
    LDFLAGS = -fsanitize=address -lopengl32 -lglu32 -lfreeglut -lIL -lILU -lILUT
endif

# Directory structure
SRC_DIR := src/classes src/generator src/aux src/engine src/xml src/engine/shaders
SRC_FILES := $(wildcard $(addsuffix /*.cpp,$(SRC_DIR)))
OBJ_DIR   := obj
OBJ_FILES := $(patsubst src/%.cpp,$(OBJ_DIR)/%.o,$(SRC_FILES))

# Generator files
GENERATOR_SRC_FILES = src/generator/generator.cpp src/generator/model.cpp src/aux/aux.cpp src/aux/curves.cpp src/generator/plane.cpp src/generator/box.cpp src/generator/sphere.cpp src/generator/cone.cpp src/generator/cylinder.cpp src/generator/bezier.cpp src/generator/torus.cpp
GENERATOR_OBJ_FILES := $(patsubst src/%.cpp,$(OBJ_DIR)/%.o,$(GENERATOR_SRC_FILES))
GENERATOR_EXECUTABLE = generator

# Engine files (define these if you need them)
ENGINE_SRC_FILES = src/engine/engine.cpp src/generator/model.cpp src/aux/aux.cpp src/xml/xml_parser.cpp src/xml/tinyxml2.cpp src/aux/curves.cpp src/engine/camera.cpp src/engine/model_handling.cpp src/engine/input_handling.cpp src/engine/shaders/shader.cpp src/engine/post_processing.cpp
ENGINE_OBJ_FILES    := $(patsubst src/%.cpp,$(OBJ_DIR)/%.o,$(ENGINE_SRC_FILES))
ENGINE_EXECUTABLE = engine

# Total number of files for progress calculation
TOTAL_FILES := $(words $(sort $(GENERATOR_SRC_FILES) $(ENGINE_SRC_FILES)))

# Default target
all: 
	@echo "Compiling $(TOTAL_FILES) source files..."
	@echo ""
	@$(MAKE) --no-print-directory build_with_progress 2> $(WARNINGS_FILE)
	@echo ""
	@echo "Compilation complete!"
	@echo -n "Show compiler warnings? [y/N] "
	@read answer; \
	if [ "$${answer,,}" = "y" ]; then \
		if [ -s $(WARNINGS_FILE) ]; then \
			echo -e "\n========== COMPILER WARNINGS ==========\n"; \
			cat $(WARNINGS_FILE); \
			echo -e "\n======================================\n"; \
		else \
			echo -e "\nNo warnings were generated."; \
		fi; \
	fi
	@rm -f .progress $(WARNINGS_FILE)

build_with_progress: reset_progress $(GENERATOR_EXECUTABLE) $(ENGINE_EXECUTABLE)

# Reset progress counter
reset_progress:
	@echo 0 > .progress

# Generator target
$(GENERATOR_EXECUTABLE): $(GENERATOR_OBJ_FILES)
	@$(CXX) $^ -o $@ $(LDFLAGS)

$(ENGINE_EXECUTABLE): $(ENGINE_OBJ_FILES)
	@$(CXX) $^ -o $@ $(LDFLAGS)

# Generic rule for object files with progress tracking
# Change dependency to src/%.cpp so that obj/generator/foo.o ← src/generator/foo.cpp
$(OBJ_DIR)/%.o: src/%.cpp
	@mkdir -p $(dir $@)
	@$(CXX) $(CXXFLAGS) -c $< -o $@
	@count=$$(cat .progress); \
	count=$$((count+1)); echo $$count > .progress; \
	percentage=$$((count * 100 / $(TOTAL_FILES))); \
	current_file=$$(basename $<); \
	printf "\r%-100s" ""; \
	if [ $$percentage -eq 100 ]; then \
		printf "\r  %3d%% (%d/%d) " $$percentage $$count $(TOTAL_FILES); \
		printf "%0.s█" $$(seq 1 50); \
		printf " All done!\n"; \
	else \
		bar_filled=$$((percentage / 2)); \
		bar_empty=$$((50 - bar_filled)); \
		printf "\r  %3d%% (%d/%d) " $$percentage $$count $(TOTAL_FILES); \
		printf "%0.s█" $$(seq 1 $$bar_filled); \
		printf "%0.s " $$(seq 1 $$bar_empty); \
		printf " Compiling %s" $$current_file; \
	fi

# Clean rule
clean:
	@echo "Cleaning up..."
	@rm -f $(OBJ_FILES) $(GENERATOR_EXECUTABLE) $(ENGINE_EXECUTABLE) .progress

clean3d:
	@echo "Cleaning up 3D files..."
	@rm -f *.3d