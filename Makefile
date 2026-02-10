# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2026/02/10 15:03:59 by jihi              #+#    #+#              #
#    Updated: 2026/02/10 17:34:02 by jihi             ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME	=	push_swap

SRC		=	src/main.c						\
			src/ft_split.c					\
			src/ft_atoi.c					\
			src/utils.c						\
			src/init_data.c					\
			src/error_check.c				\
			src/node_handling.c				\
			src/operations.c				\
			src/sort.c						\
			src/init_two_args.c				\

OBJ_DIR	=	obj
OBJ		=	$(SRC:src/%.c=$(OBJ_DIR)/%.o)

CC		=	cc
CFLAGS	=	-Wall -Wextra -Werror -g
HEADERS	=	-Iincludes
RM		=	rm -rf

all: $(NAME)

$(NAME): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) -o $(NAME)

$(OBJ_DIR)/%.o: src/%.c
	mkdir -p $(OBJ_DIR)
	$(CC) $(CFLAGS) $(HEADERS) -c $< -o $@

clean:
	$(RM) $(OBJ_DIR)

fclean: clean
	$(RM) $(NAME)

re: fclean all

.PHONY: all clean fclean re
