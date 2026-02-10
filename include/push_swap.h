/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   push_swap.h                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: jihi <jihi@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2026/02/10 15:01:35 by jihi              #+#    #+#             */
/*   Updated: 2026/02/10 17:45:50 by jihi             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PUSH_SWAP_H
# define PUSH_SWAP_H

# include <stddef.h>
# include <stdio.h>
# include <unistd.h>
# include <stdlib.h>

typedef struct s_node
{
	int				nb;
	int				index;
	struct s_node	*next;
}	t_node;

typedef struct s_data
{
	t_node	*a;
	t_node	*b;
	int		nb_args;
}	t_data;

void			init_data(int ac, char **av, t_data *data);
char			**ft_split(char *s, char c);
void			free_all(t_data *data, int exit_value);
int				ft_putstr(char *str);
void			add_back(t_node **list, t_node *new);
t_node			*add_new(int nb);
long long int	ft_atoi(char *str);
void			ft_putnbr(int nb);
int				error_check(int ac, char **av);
void			sa(t_data *data);
void			pa(t_data *data);
void			pb(t_data *data);
void			ra(t_data *data);
void			rra(t_data *data);
void			sort_three(t_data *data);
void			sort_four(t_data *data);
void			sort_five(t_data *data);
void			bitwise_alg(t_data *data);
void			create_data_from_string(char *str, t_data *data);

#endif