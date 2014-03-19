function [gameLength matchLength gameWinner matchWinner] = comparePARSystem(playerA_pr, nPaths, isPAR, winningPoint)
% comparePARSystem Plays nPaths squash matches between two players with a
%                  specified probability of dominance to measure outcomes
%                  between the PAR scoring system and the HiHo scoring
%                  system.
%
% [gameLength matchLength gameWinner matchWinner] =
% 	comparePARSystem(playerA_probability, nPaths, isPAR, winnindPoint)
%
%  Parameter            Value
%  ---------            -----
%  'playerA_pr'         Probability of player A winning over player B (a
%                       measure of player A's strength).
%  'nPaths'             Number of simulations (number of matches).
%  'isPAR'              True (PAR) or false (HiHo-9).
%  'winningPoint'       Scalar number indicating the final number of points
%                       needed to win a game.
%
%
%  Output               Value
%  ------               -----
%  'gameLength'         nPath x 5 matrix of rally counts.
%  'matchLength'        nPath x 1 vector of match length (game count).
%  'gameWinner'         nPath x 5 matrix of game winner id (1 = player A, 2
%                       = player B).
%  'matchWinner'        nPath x 1 vector of match winner id (1 = player A, 2
%                       = player B).


%     Created: Cel Kulasekaran 
%        Date: 08/06/2009
% Last Update: 
%
%
% File Dependencies
% -----------------
% 1. 
% 
%
% References
% ----------
% 1. 
%
%
% Notes
% -----
% 1. Thanks to Mohan Mathew for suggesting this experiment
% 2. also to Bob Dyer, Ripley Hastings, Dan Reagan, and 
%    Girish Venkataramani for helpful comments




%% Notes: Some of the things we can look at
% 1. Determine how often the better player wins
% 2. Measure margins of victory
% 3. Game length
% 4. Match length
% 5. Process stats (might be more transparent to disect the data in Excel)


% assumes binomial distribution
% i.i.d
% Can we vectorize this later? PAR-11 most certainly
% I am not so sure about HiHo-9, path dependencies? 


%% Let's start
% memory allocation
gameLength = zeros(nPaths, 5);
matchLength = zeros(nPaths, 1);
gameWinner = zeros(nPaths, 5);
matchWinner = zeros(nPaths, 1);

% store winningPoint (HiHo will modify this)
stopPoint = winningPoint;


%% For nPaths number of matches, let the games begin
for N = 1:nPaths
   
   % There are five games per match in squash (best out of five)
   for gameNumber = 1:5
      
      % if the match winner is not found, let's play a game
      if matchWinner(N, 1) < 1
         % track the match length
         matchLength(N) = matchLength(N) + 1;
      
         % init rally winner and rally score between both players
         rallyWinner = [0 0];
         rallyScore = [0 0];
         lastRally = [0 0];

         % while we haven't found a game winner, let's move on to the next
         % rally
         while gameWinner(N, gameNumber) < 1
            p = binornd(1, playerA_pr); % probability of player A scoring
            q = 1-p;
            
            
            if ~isPAR
               % HiHo scoring
               if sum(lastRally == [0 0], 2) == 2
                  q = (1-p);
               elseif sum(lastRally == [1 0], 2) == 2
                  q = 0;
               elseif sum(lastRally == [0 1], 2) == 2
                  p = 0;
                  q = binornd(1, 1-playerA_pr);
               end

               % store for last rally (path dependent for HiHo)
               lastRally = [p q];
            end
            
            

            % Score!
            rallyScore = rallyScore + [p q];
            
            % track number of games played
            gameLength(N, gameNumber) = gameLength(N, gameNumber) + 1;
            
            % check for tied score prior to win
            if sum(rallyScore == [winningPoint-1 winningPoint-1], 2) == 2
                  %% Tie-Break!
                  if isPAR
                     %% PAR system Tie-break
                     % must win by 2 clear points
                     if diff(rallyScore) == 2;
                        rallyWinner = [0 1];
                        gameWinner(N, gameNumber) = find(rallyWinner);
                     elseif diff(rallyScore) == -2
                        rallyWinner = [1 0];
                        gameWinner(N, gameNumber) = find(rallyWinner);
                     end
                  else
                     %% HiHo tie break
                     % calculate toss for playing to either +1 or +2 points
                     % from tie
                     if (unidrnd(2)-1) == 1
                        stopPoint = winningPoint+1;
                     end
                  end
            else
               %% Continue the rally (not tie-break)
               % check to see if we have reached (winningPoint) yet
               if max(rallyScore) == stopPoint
                  rallyWinner(find(rallyScore == stopPoint)) = 1; %#ok<FNDSB>
                  gameWinner(N, gameNumber) = find(rallyWinner); % winner found
               end
            end
         end
            
         % figure out who won the game
         if ~isempty(find(rallyWinner))  %#ok<EFIND>
            gameWinner(N, gameNumber) = find(rallyWinner); 
         end
      end

      
      % figure out who won the match
      if length(find(gameWinner(N, :) == 1))  == 3
         matchWinner(N, 1) = 1;
      elseif length(find(gameWinner(N, :) == 2)) == 3
         matchWinner(N, 1) = 2;
      end
        
   end
   
end


