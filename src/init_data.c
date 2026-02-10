/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   init_data.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/10 15:07:18 by jihi              #+#    #+#             */
/*   Updated: 2026/02/10 15:20:47 by jihi             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/push_swap.h"

void	create_nodes(int ac, char **av, t_data *data)
{
	(void)ac;
	(void)av;
	(void)data;
}

void	init_data(int ac, char **av, t_data *data)
{
	data->nb_args = ac;
	data->a = malloc(sizeof(t_node));
	if (!data->a)
		free_all(data, -1);
	create_nodes(ac, av, data);
}