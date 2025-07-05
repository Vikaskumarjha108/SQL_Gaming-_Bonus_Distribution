/*1. Find Playerwise Loyalty points earned by Players in the following slots:-*/
   /* a. 2nd October Slot S1*/
   SELECT player_id, 
               SUM(0.01 * CASE WHEN activity_type = 'Deposit' THEN amount ELSE 0 END) +
               SUM(0.005 * CASE WHEN activity_type = 'Withdrawal' THEN amount ELSE 0 END) +
               SUM(0.2 * num_games) +
               (0.001 * GREATEST(SUM(deposit_count - withdrawal_count), 0)) AS total_loyalty_points
        FROM( select * from master_activity_data
 where timing between '02-10-2022 00:00' and '02-10-2022 11:59'
 group by player_id) as timeslot group by player_id
 order by total_loyalty_points desc

   /* b. 16th October Slot S2*/
   SELECT player_id, 
               SUM(0.01 * CASE WHEN activity_type = 'Deposit' THEN amount ELSE 0 END) +
               SUM(0.005 * CASE WHEN activity_type = 'Withdrawal' THEN amount ELSE 0 END) +
               SUM(0.2 * num_games) +
               (0.001 * GREATEST(SUM(deposit_count - withdrawal_count), 0)) AS total_loyalty_points
        FROM( select * from master_activity_data
 where timing between '16-10-2022 12:00' and '16-10-2022 23:59'
 group by player_id) as timeslot group by player_id
 order by total_loyalty_points desc

   
  /*  b. 18th October Slot S1*/
  SELECT player_id, 
               SUM(0.01 * CASE WHEN activity_type = 'Deposit' THEN amount ELSE 0 END) +
               SUM(0.005 * CASE WHEN activity_type = 'Withdrawal' THEN amount ELSE 0 END) +
               SUM(0.2 * num_games) +
               (0.001 * GREATEST(SUM(deposit_count - withdrawal_count), 0)) AS total_loyalty_points
        FROM( select * from master_activity_data
 where timing between '18-10-2022 00:00' and '18-10-2022 11:59'
 group by player_id) as timeslot group by player_id
 order by total_loyalty_points desc

  
  /*    b. 26th October Slot S2*/
  SELECT player_id, 
               SUM(0.01 * CASE WHEN activity_type = 'Deposit' THEN amount ELSE 0 END) +
               SUM(0.005 * CASE WHEN activity_type = 'Withdrawal' THEN amount ELSE 0 END) +
               SUM(0.2 * num_games) +
               (0.001 * GREATEST(SUM(deposit_count - withdrawal_count), 0)) AS total_loyalty_points
        FROM( select * from master_activity_data
 where timing between '26-10-2022 12:00' and '26-10-2022 23:59'
 group by player_id) as timeslot group by player_id
 order by total_loyalty_points desc

  
/*2. Calculate overall loyalty points earned and rank players on the basis of loyalty points in the month of October. */
SELECT player_id, total_loyalty_points, 
           RANK() OVER (ORDER BY total_loyalty_points DESC) AS arank
    FROM (
        SELECT player_id, 
               SUM(0.01 * CASE WHEN activity_type = 'Deposit' THEN amount ELSE 0 END) +
               SUM(0.005 * CASE WHEN activity_type = 'Withdrawal' THEN amount ELSE 0 END) +
               SUM(0.2 * num_games) +
               (0.001 * GREATEST(SUM(deposit_count - withdrawal_count), 0)) AS total_loyalty_points
        FROM master_activity_data
        GROUP BY player_id
    ) AS loyalty_data


/*3. What is the average deposit amount?*/
SELECT round(AVG(user_deposit),2) AS avg_deposit_per_user
FROM (
    SELECT player_id, SUM(amount) AS user_deposit
    FROM master_activity_data 
    WHERE activity_type = 'Deposit' 
    GROUP BY player_id
) AS deposits_per_user;

/*4. What is the average deposit amount per user in a month?*/
SELECT player_id, SUM(amount)/Count(player_id) AS avg_user_deposit
    FROM master_activity_data 
    WHERE activity_type = 'Deposit' 
    GROUP BY player_id

/*5. What is the average number of games played per user?*/

SELECT round(AVG(total_games),0) AS avg_games_per_user
FROM (
    SELECT player_id, SUM(num_games) AS total_games
    FROM master_activity_data 
    WHERE activity_type = 'Game'
    GROUP BY player_id
) AS games_per_user;


/*Part B - How much bonus should be allocated to leaderboard players?
After calculating the loyalty points for the whole month find out which 50 players are at the top of the leaderboard. The company has allocated a pool of Rs 50000 to be given away as bonus money to the loyal players.
Now the company needs to determine how much bonus money should be given to the players.*/
WITH ranked_players AS (
    SELECT player_id, total_loyalty_points, 
           RANK() OVER (ORDER BY total_loyalty_points DESC) AS arank
    FROM (
        SELECT player_id, 
               SUM(0.01 * CASE WHEN activity_type = 'Deposit' THEN amount ELSE 0 END) +
               SUM(0.005 * CASE WHEN activity_type = 'Withdrawal' THEN amount ELSE 0 END) +
               SUM(0.2 * num_games) +
               (0.001 * GREATEST(SUM(deposit_count - withdrawal_count), 0)) AS total_loyalty_points
        FROM master_activity_data
        GROUP BY player_id
    ) AS loyalty_data
)
SELECT player_id, total_loyalty_points, arank as rank_on_points,
       (total_loyalty_points / (SELECT SUM(total_loyalty_points) FROM ranked_players WHERE arank <= 50)) * 50000 AS allocated_bonus
FROM ranked_players
WHERE arank <= 50;


