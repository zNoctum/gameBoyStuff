bin/%.o: src/%.asm
	rgbasm -o $@ $< -iinclude
bin/main.gb: bin/main.o
	rgblink -o $@ $^
	rgbfix -v -p 0 $@
clean:
	rm bin/*
	rm obj/*
