/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   sorting_utils.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/12 14:47:11 by jihi              #+#    #+#             */
/*   Updated: 2026/02/12 20:54:02 by jihi             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/push_swap.h"

int	get_pos_index(t_node *node, int index)
{
	int	pos;

	pos = 0;
	while (node)
	{
		if (node->index == index)
			return (pos);
		pos++;
		node = node->next;
	}
	return (-1);
}

int	get_len_list(t_node *node)
{
	int	len;

	len = 0;
	while (node)
	{
		len++;
		node = node->next;
	}
	return (len);
}

void	put_pos_to_top(t_data *data, int pos)
{
	int	len;
	int	i;

	len = get_len_list(data->a);
	i = len - pos;
	if (pos <= len / 2)
	{
		while (pos-- > 0)
			ra(data);
	}
	else
		while (i-- > 0)
			rra(data);
}
