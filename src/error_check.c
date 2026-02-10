/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   error_check.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/01/30 13:07:15 by hnayel            #+#    #+#             */
/*   Updated: 2026/02/10 15:57:08 by jihi             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/push_swap.h"

int	check_dup(char **av)
{
	int	i;
	int	j;

	i = 1;
	while (av[i + 1])
	{
		j = 1;
		while (av[i + j])
		{
			if (ft_atoi(av[i]) == ft_atoi(av[i + j]))
				return (1);
			j++;
		}
		i++;
	}
	return (0);
}

int	check_string_arg(char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		if ((str[i] < '0' || str[i] > '9') && str[i] != ' ' && str[i] != '-')
			return (1);
		if (i > 0 && str[i] == '-' && str[i - 1] <= '9' && str[i - 1] >= '0')
			return (1);
		i++;
	}
	return (0);
}

int	number_check(int ac, char **av)
{
	int	i;
	int	j;

	i = 1;
	while (i < ac)
	{
		j = 0;
		while (av[i][j])
		{
			if (j == 0 && av[i][j] == '-')
				j++;
			if (!(av[i][j] <= '9' && av[i][j] >= '0'))
				return (1);
			j++;
		}
		i++;
	}
	return (0);
}

int	check_int_min_max(int ac, char **av)
{
	int	i;

	i = 0;
	while (i < ac)
	{
		if (ft_atoi(av[i]) > 2147483647 || ft_atoi(av[i]) < -2147483648)
			return (1);
		i++;
	}
	return (0);
}

int	error_check(int ac, char **av)
{
	if (ac < 2)
		return (1);
	if (ac == 2 && check_string_arg(av[1]) == 1)
		return (-1);
	if (number_check(ac, av) == 1 && ac > 2)
		return (-1);
	if (check_int_min_max(ac, av) == 1)
		return (-1);
	if (check_dup(av) == 1)
		return (-1);
	return (0);
}
