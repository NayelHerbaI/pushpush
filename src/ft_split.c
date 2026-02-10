/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_split.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/10 15:00:41 by jihi              #+#    #+#             */
/*   Updated: 2026/02/10 15:00:43 by jihi             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/push_swap.h"

int	find_tab_size(char *s, char c)
{
	int	i;
	int	count;

	i = 0;
	count = 0;
	while (s[i])
	{
		if (s[i + 1] && s[i] == c && s[i + 1] != c)
			count++;
		if (s[i] != c && i == 0)
			count++;
		i++;
	}
	return (count);
}

char	*ft_copy(char *s, char c)
{
	int		i;
	char	*cpy;

	i = 0;
	while (*s && *s == c)
		s++;
	while (s[i] && s[i] != c)
		i++;
	cpy = malloc(sizeof(char) * i + 1);
	if (cpy == NULL)
		return (NULL);
	i = 0;
	while (s[i] && s[i] != c)
	{
		cpy[i] = s[i];
		i++;
	}
	cpy[i] = '\0';
	return (cpy);
}

char	**second_split(char *s, char c, char **tab)
{
	int	i;
	int	j;

	i = -1;
	j = 0;
	while (s[++i])
	{
		if ((s[i] == c && s[i + 1] != c && s[i + 1])
			|| (i == 0 && s[i] != c))
		{
			tab[j] = ft_copy(&s[i + 1 - (i == 0)], c);
			if (tab[j] == NULL)
				return (NULL);
			j++;
		}
	}
	tab[j] = NULL;
	return (tab);
}

char	**ft_split(char *s, char c)
{
	int		tab_size;
	char	**tab;

	if ((!s && !c) || (s[0] == '\0' && c == 'z'))
	{
		tab = (char **)malloc(sizeof(char *));
		tab[0] = 0;
		return (tab);
	}
	tab_size = find_tab_size(s, c);
	tab = malloc(sizeof(char *) * (tab_size + 1));
	if (tab == NULL)
		return (NULL);
	return (second_split(s, c, tab));
}
