/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   init_two_args.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/10 17:31:34 by jihi              #+#    #+#             */
/*   Updated: 2026/02/12 17:22:20 by jihi             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/push_swap.h"

void	free_split(char **tab)
{
	int	i;

	i = 0;
	if (!tab)
		return ;
	while (tab[i])
	{
		free(tab[i]);
		i++;
	}
	free(tab);
}
int	create_data_from_string(char *str, t_data *data)
{
	char	**tab;
	int		i;

	tab = ft_split(str, ' ');
	if (!tab || !tab[0])
	{
		free_split(tab);
		write(2, "Error\n", 6);
		free_all(data, -1);
	}
	i = 0;
	while (tab[i])
		i++;
	if (error_check(i, tab, 0) != 0)
	{
		free_split(tab);
		write(2, "Error\n", 6);
		free_all(data, -1);
	}
	init_data(i + 1, tab, data);
	data->nb_args = i;
	free_split(tab);
	return (0);
}
