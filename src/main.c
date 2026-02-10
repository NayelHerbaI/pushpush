/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/10 15:01:01 by jihi              #+#    #+#             */
/*   Updated: 2026/02/10 18:09:43 by jihi             ###   ########.fr       */
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

void	print_stacks(t_data *data)
{
	t_node	*tmp;

	ft_putstr("---- STACK A ----\n");
	tmp = data->a;
	while (tmp)
	{
		ft_putstr("nb = ");
		ft_putnbr(tmp->nb);
		ft_putstr(" | index = ");
		ft_putnbr(tmp->index);
		ft_putstr("\n");
		tmp = tmp->next;
	}

	ft_putstr("---- STACK B ----\n");
	tmp = data->b;
	while (tmp)
	{
		ft_putstr("nb = ");
		ft_putnbr(tmp->nb);
		ft_putstr(" | index = ");
		ft_putnbr(tmp->index);
		ft_putstr("\n");
		tmp = tmp->next;
	}
	ft_putstr("-----------------\n");
}

void	pick_sort(t_data *data)
{
	if (data->nb_args == 2)
		sa(data);
	else if (data->nb_args == 3)
		sort_three(data);
	else if (data->nb_args == 4)
		sort_four(data);
	else if (data->nb_args == 5)
		sort_five(data);
	else
		bitwise_alg(data);
}

int	is_list_not_sorted(t_data *data)
{
	t_node	*head;

	head = data->a;
	while (head->next != NULL)
	{
		if (head->index > head->next->index)
			return (1);
		head = head->next;
	}
	return (0);
}

int	main(int ac, char **av)
{
	t_data	*data;

	data = malloc(sizeof(t_data));
	if (!data)
		exit(-1);
	if (ac < 2 || error_check(ac, av) != 0)
		return (ft_putstr("Error\n"));
	if (ac == 2)
		create_data_from_string(av[1], data);
	else
		init_data(ac, &av[1], data);
	while (is_list_not_sorted(data) == 1)
	{
		pick_sort(data);
	}
	print_stacks(data);
	free_all(data, 1);
	return (0);
}
