/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   operations.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/10 16:19:28 by jihi              #+#    #+#             */
/*   Updated: 2026/02/10 16:58:17 by jihi             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/push_swap.h"

void	sa(t_data *data)
{
	t_node	*first;
	t_node	*second;

	if (!data || !data->a || !data->a->next)
		return ;
	first = data->a;
	second = data->a->next;
	first->next = second->next;
	second->next = first;
	data->a = second;
	ft_putstr("sa\n");
}

void	pa(t_data *data)
{
	t_node	*tmp;

	if (!data || !data->b)
		return ;
	tmp = data->b;
	data->b = data->b->next;
	tmp->next = data->a;
	data->a = tmp;
	ft_putstr("pa\n");
}

void	pb(t_data *data)
{
	t_node	*tmp;

	if (!data || !data->a)
		return ;
	tmp = data->a;
	data->a = data->a->next;
	tmp->next = data->b;
	data->b = tmp;
	ft_putstr("pb\n");
}

void	ra(t_data *data)
{
	t_node	*first;
	t_node	*last;

	if (!data || !data->a || !data->a->next)
		return ;
	first = data->a;
	data->a = first->next;
	first->next = NULL;
	last = data->a;
	while (last->next)
		last = last->next;
	last->next = first;
	ft_putstr("ra\n");
}

void	rra(t_data *data)
{
	t_node	*penultimate;
	t_node	*last;

	if (!data || !data->a || !data->a->next)
		return ;
	penultimate = NULL;
	last = data->a;
	while (last->next)
	{
		penultimate = last;
		last = last->next;
	}
	penultimate->next = NULL;
	last->next = data->a;
	data->a = last;
	ft_putstr("rra\n");
}