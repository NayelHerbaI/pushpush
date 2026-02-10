/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/10 15:01:01 by jihi              #+#    #+#             */
/*   Updated: 2026/02/10 16:13:37 by jihi             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/push_swap.h"

void	free_all(t_data *data, int exit_value)
{
	t_node	*tmp;

	if (data->a)
	{
		while (data->a != NULL)
		{
			tmp = data->a;
			data->a = data->a->next;
			free(tmp);
		}
	}
	if (data->b)
	{
		while (data->b != NULL)
		{
			tmp = data->b;
			data->b = data->b->next;
			free(tmp);
		}
	}
	free(data);
	exit(exit_value);
}

void	ft_puterror(char *message, t_data *data)
{
	ft_putstr(message);
	free_all(data, -1);
}

void	print_list(t_data *data)
{
	t_node	*lst;

	lst = data->a;
	while (lst)
	{
		printf("nb = %d | index = %d\n", lst->nb, lst->index);
		lst = lst->next;
	}
}

int	main(int ac, char **av)
{
	t_data	*data;

	data = malloc(sizeof(t_data));
	if (!data)
		exit (-1);
	if (ac < 2 || error_check(ac, av) != 0)
		ft_putstr("Error\n");
	init_data(ac, av, data);
	print_list(data);
	free_all(data, 1);
	return (0);
}
