/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   init_data.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/10 15:07:18 by jihi              #+#    #+#             */
/*   Updated: 2026/02/10 16:13:32 by jihi             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/push_swap.h"

t_node	*create_list(int ac, char **av)
{
	int		i;
	t_node	*list;
	t_node	*new;

	list = NULL;
	i = 1;
	while (i < ac)
	{
		new = add_new(ft_atoi(av[i]));
		if (!new)
			return (NULL);
		add_back(&list, new);
		i++;
	}
	return (list);
}

void	assign_index(t_node *list)
{
	int		index;
	t_node	*curr;
	t_node	*cmp;

	curr = list;
	while (curr)
	{
		index = 0;
		cmp = list;
		while (cmp)
		{
			if (cmp->nb < curr->nb)
				index++;
			cmp = cmp->next;
		}
		curr->index = index;
		curr = curr->next;
	}
}

void	init_data(int ac, char **av, t_data *data)
{
	data->nb_args = ac;
	data->a = create_list(ac, av);
	if (!data->a)
		free_all(data, -1);
	data->b = NULL;
	assign_index(data->a);
}
