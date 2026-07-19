all:
	@bash .system/launch.sh run

re: fclean all

gradejustinstall:
	@bash .system/launch.sh gradejustinstall

grade: clean
	@bash .system/launch.sh grade

clean:
	@rm -f .system/*.o
	@rm -rf .system/a.out.dSYM

fclean: clean
	@rm -f .system/a.out .system/readline_ok .system/.devmake.err

help:
	@echo "\x1B[37mType \x1B[32m> make \x1B[37mto start the exam"
