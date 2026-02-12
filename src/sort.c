/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   sort.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/10 16:59:51 by jihi              #+#    #+#             */
/*   Updated: 2026/02/12 17:02:16 by jihi             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/push_swap.h"

void	sort_three(t_data *data)
{
	int	f;
	int	s;
	int	t;

	if (!data || !data->a || !data->a->next || !data->a->next->next)
		return ;
	f = data->a->index;
	s = data->a->next->index;
	t = data->a->next->next->index;
	if (f < t && t < s)
	{
		sa(data);
		ra(data);
	}
	else if (s < f && f < t)
		sa(data);
	else if (s < t && t < f)
		ra(data);
	else if (t < f && f < s)
		rra(data);
	else if (t < s && s < f)
	{
		sa(data);
		rra(data);
	}
}
void	sort_four(t_data *data)
{
	int	pos_min;

	pos_min = get_pos_index(data->a, 0);
	put_pos_to_top(data, pos_min);
	pb(data);
	sort_three(data);
	pa(data);
}

void	sort_five(t_data *data)
{
	int	pos;

	pos = get_pos_index(data->a, 0);
	put_pos_to_top(data, pos);
	pb(data);
	pos = get_pos_index(data->a, 1);
	put_pos_to_top(data, pos);
	pb(data);
	sort_three(data);
	pa(data);
	pa(data);
}

void	bitwise_alg(t_data *data)
{
	(void)data;
}
