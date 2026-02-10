/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/10 15:01:01 by jihi              #+#    #+#             */
/*   Updated: 2026/02/10 15:23:31 by jihi             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/push_swap.h"

void	free_all(t_data *data, int exit_value)
{
	if (data->a != NULL)
		free(data->a);
	if (data->b != NULL)
		free(data->b);
	if (data != NULL)
		free(data);
	exit(exit_value);
}

void	ft_puterror(char *message, t_data *data)
{
	ft_putstr(message);
	free_all(data, -1);
}
int	main(int ac, char **av)
{
	t_data	*data;

	data = malloc(sizeof(t_data));
	if (!data)
		exit (-1);
	data->a = NULL;
	data->b = NULL;
	if (ac < 2)
		ft_puterror("Error\n", data);
	init_data(ac, av, data);
	free_all(data, 1);
	return (0);
}