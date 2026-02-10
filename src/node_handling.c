/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   node_handling.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/10 15:45:34 by jihi              #+#    #+#             */
/*   Updated: 2026/02/10 15:49:37 by jihi             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/push_swap.h"

t_node	*add_new(int nb)
{
	t_node	*node;

	node = malloc(sizeof(t_node));
	if (!node)
		return (NULL);
	node->index = -1;
	node->nb = nb;
	node->next = NULL;
	return (node);
}

void	add_back(t_node **list, t_node *new)
{
	t_node	*curr;

	if (!*list)
	{
		*list = new;
		return ;
	}
	curr = *list;
	while (curr->next)
		curr = curr->next;
	curr->next = new;
}