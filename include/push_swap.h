/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   push_swap.h                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/10 15:01:35 by jihi              #+#    #+#             */
/*   Updated: 2026/02/10 15:25:12 by jihi             ###   ########.fr       */
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
	int		nb;
	int		index;
	void	*next;
}t_node;

typedef struct s_data
{
	t_node	*a;
	t_node	*b;
	int		nb_args;
}t_data;

void	init_data(int ac, char **av, t_data *data);
void	free_all(t_data *data, int exit_value);
void	ft_putstr(char *str);

#endif