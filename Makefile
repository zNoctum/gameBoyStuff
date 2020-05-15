obj/%.o: src/%.asm
	rgbasm -o $@ $< -iinclude
bin/main.gb: obj/main.o
	rgblink -o $@ $^
	rgbfix -v -p 0 $@
clean:
	rm bin/*
	rm obj/*