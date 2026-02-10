/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_atoi.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: hnayel <hnayel@student.42.fr>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/01/30 13:07:21 by hnayel            #+#    #+#             */
/*   Updated: 2026/01/30 13:07:22 by hnayel           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/push_swap.h"

long long int	ft_atoi(char *str)
{
	long long int	res;
	long long int	sign;
	long long int	i;

	res = 0;
	sign = 1;
	i = 0;
	while ((str[i] <= 13 && str[i] >= 9) || str[i] == 32)
		i++;
	if (str[i] == '-')
	{
		i++;
		sign = -1;
	}
	else if (str[i] == '+')
		i++;
	while (str[i] >= '0' && str[i] <= '9')
	{
		res = (str[i] - 48) + res * 10;
		i++;
	}
	return (res * sign);
}
