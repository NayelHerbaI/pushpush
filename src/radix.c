/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   radix.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/12 22:32:06 by jihi              #+#    #+#             */
/*   Updated: 2026/02/12 22:50:47 by jihi             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/push_swap.h"

int	max_bit(int n)
{
	int	bits;
	int	max;

	bits = 0;
	max = n - 1;
	while ((max >> bits) != 0)
		bits++;
	return (bits);
}

void	radix(t_data *data)
{
	int	i;
	int	j;
	int	bits;
	int	n;

	n = data->nb_args;
	bits = max_bit(n);
	i = 0;
	while (i < bits)
	{
		j = 0;
		while (j < n)
		{
			if (((data->a->index >> i) & 1) == 0)
				pb(data);
			else
				ra(data);
			j++;
		}
		while (data->b)
			pa(data);
		i++;
	}
}
