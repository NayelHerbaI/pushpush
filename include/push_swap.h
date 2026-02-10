/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   push_swap.h                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/10 15:01:35 by jihi              #+#    #+#             */
/*   Updated: 2026/02/10 15:57:29 by jihi             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PUSH_SWAP_H
#define PUSH_SWAP_H

# include <stddef.h>
# include <stdio.h>
# include <unistd.h>
# include <stdlib.h>

typedef struct s_node
{
	int				nb;
	int				index;
	struct s_node	*next;
}t_node;

typedef struct s_data
{
	t_node	*a;
	t_node	*b;
	int		nb_args;
}t_data;

void			init_data(int ac, char **av, t_data *data);
void			free_all(t_data *data, int exit_value);
void			ft_putstr(char *str);
void			add_back(t_node **list, t_node *new);
t_node			*add_new(int nb);
long long int	ft_atoi(char *str);
int				error_check(int ac, char **av);

#endif