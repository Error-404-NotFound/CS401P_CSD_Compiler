CFLAGS = -g -DDEBUG
CC = g++
PYTHON = python3
BASENAME := $(basename $(notdir $(FILE)))

# Default target
run: parser
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make run FILE=<input-file>"; exit 1; \
	fi
	@if [ ! -f "$(FILE)" ]; then \
		echo "Error: file '$(FILE)' not found"; exit 1; \
	fi
	@echo "Running parser on $(FILE)..."
	@case "$(FILE)" in \
		*.rcb) ;; \
		*) echo "Error: file must have .rcb extension"; exit 1; ;; \
	esac
	./parser < "$(FILE)" > "$(BASENAME).tac"

# Run with LLM optimization
run-optimized: parser
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make run-optimized FILE=<input-file>"; exit 1; \
	fi
	@if [ ! -f "$(FILE)" ]; then \
		echo "Error: file '$(FILE)' not found"; exit 1; \
	fi
	@echo "=== Generating TAC ==="
	@case "$(FILE)" in \
		*.rcb) ;; \
		*) echo "Error: file must have .rcb extension"; exit 1; ;; \
	esac
	@./parser < "$(FILE)" > "$(BASENAME).tac"
	@echo ""
	# Run optimization (output: $(FILE)_optimized.tac)
	$(PYTHON) optimize_tac.py "$(BASENAME).tac" "$(BASENAME)_optimized.tac"
	@echo ""
	@echo "=== Optimization Complete ==="
	@echo "Original TAC: $(BASENAME).tac"
	@echo "Optimized TAC: $(BASENAME)_optimized.tac"

# Interactive mode - asks user if they want optimization
run-interactive: parser
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make run-interactive FILE=<input-file>"; exit 1; \
	fi
	@if [ ! -f "$(FILE)" ]; then \
		echo "Error: file '$(FILE)' not found"; exit 1; \
	fi
	@echo "=== Generating TAC ==="
	@case "$(FILE)" in \
		*.rcb) ;; \
		*) echo "Error: file must have .rcb extension"; exit 1; ;; \
	esac
	@./parser < "$(FILE)" > "$(BASENAME).tac"
	@echo ""
	@echo "TAC generated successfully in $(BASENAME).tac"
	@echo ""
	@read -p "Do you want to optimize the TAC using Mistral LLM? (y/n): " answer; \
	if [ "$$answer" = "y" ] || [ "$$answer" = "Y" ]; then \
		echo ""; \
		echo "=== Running LLM Optimization ==="; \
		$(PYTHON) optimize_tac.py "$(BASENAME).tac" "$(BASENAME)_optimized.tac"; \
		echo ""; \
		echo "=== Results ==="; \
		echo "Original TAC: $(BASENAME).tac"; \
		echo "Optimized TAC: $(BASENAME)_optimized.tac"; \
		else \
			echo "Skipping optimization. TAC saved in $(BASENAME).tac"; \
	fi

# Build parser
parser: y.tab.c lex.yy.c y.tab.h
	${CC} -w y.tab.c lex.yy.c -ll -o parser

# Generate lexer
lex.yy.c: lexer.l
	lex lexer.l

# Generate parser
y.tab.c: parser.y
	yacc -v -d -t parser.y

# Install Python dependencies
install-deps:
	@echo "Installing Python dependencies..."
	pip3 install mistralai

# Check if dependencies are installed
check-deps:
	@echo "Checking dependencies..."
	@$(PYTHON) -c "import mistralai" 2>/dev/null && echo "✓ mistralai installed" || echo "✗ mistralai not installed (run: make install-deps)"
	@if [ -n "$$MISTRAL_API_KEY" ]; then \
		echo "✓ MISTRAL_API_KEY is set"; \
	else \
		echo "✗ MISTRAL_API_KEY not set"; \
	fi

# Compare original and optimized TAC
compare:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make compare FILE=<input-file>"; exit 1; \
	fi
	@if [ ! -f "$(BASENAME).tac" ]; then \
		echo "Error: $(BASENAME).tac not found. Run 'make run FILE=$(FILE)' first."; \
		exit 1; \
	fi
	@if [ ! -f "$(BASENAME)_optimized.tac" ]; then \
		echo "Error: $(BASENAME)_optimized.tac not found. Run 'make run-optimized FILE=$(FILE)' first."; \
		exit 1; \
	fi
	@echo "=== TAC Comparison ==="
	@echo "Original lines: $$(wc -l < $(BASENAME).tac)"
	@echo "Optimized lines: $$(wc -l < $(BASENAME)_optimized.tac)"
	@echo ""
	@echo "Use 'diff $(BASENAME).tac $(BASENAME)_optimized.tac' to see detailed differences"

# Clean build artifacts
clean:
	rm -f parser y.tab.c lex.yy.c lexer y.tab.h y.output *.out *.exe *.txt *.tac

# Clean everything including TAC files
clean-all: clean
	rm -f *.txt

# Help target
help:
	@echo "Available targets:"
	@echo "  make run              - Generate TAC without optimization"
	@echo "  make run-optimized    - Generate and optimize TAC"
	@echo "  make run-interactive  - Generate TAC and ask user about optimization"
	@echo "  make install-deps     - Install Python dependencies"
	@echo "  make check-deps       - Check if dependencies are installed"
	@echo "  make compare          - Compare original and optimized TAC"
	@echo "  make clean            - Remove build artifacts"
	@echo "  make clean-all        - Remove all generated files including TAC"
	@echo "  make help             - Show this help message"
	@echo ""
# 	@echo "Environment variables:"
# 	@echo "  MISTRAL_API_KEY       - Your Mistral API key (required for optimization)"

.PHONY: run run-optimized run-interactive install-deps check-deps compare clean clean-all help
