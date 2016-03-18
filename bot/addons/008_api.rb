# encoding: utf-8

=begin
    Bot LaPrimaire.org helps french citizens participate to LaPrimaire.org
    Copyright (C) 2016 Telegraph.ai

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

module Api
	def self.included(base)
		puts "loading Api add-on" if DEBUG
		messages={
			:fr=>{
				:api=>{
					:access_granted=><<-END,
Bonne nouvelle %{firstname}, vous avez désormais accès à LaPrimaire.org... c'est reparti ! #{Bot.emoticons[:face_sunglasses]}
END
					:allow_user=><<-END,
Bonne nouvelle %{firstname}, votre accès à LaPrimaire.org a été réinitialisé... c'est reparti ! #{Bot.emoticons[:face_sunglasses]}
END
					:unblock_user=><<-END,
Bonne nouvelle %{firstname}, votre accès à LaPrimaire.org a été rétabli... c'est reparti ! #{Bot.emoticons[:face_sunglasses]}
END
					:block_candidate_reviews=><<-END,
%{firstname}, il semblerait que vous ne soyez pas très doué pour noter les candidats ou alors que vous ne les notez pas assez sérieusement. En effet, vous avez accepté des fausses candidatures et/ou rejeté des vraies candidatures. Je dois donc suspendre votre capacité à noter les candidats #{Bot.emoticons[:crying_face]}
END
					:block_candidate_proposals=><<-END,
%{firstname}, parmi les candidats que vous avez proposés, un nombre trop important était de faux candidats. Je suis donc dans l'obligation de suspendre votre capacité à proposer de nouveaux candidats #{Bot.emoticons[:crying_face]}
END
					:ban_user=><<-END,
%{firstname}, votre comportement sur LaPrimaire.org est en violation de la charte que vous avez acceptée, par conséquent je suis donc dans l'obligation de suspendre votre compte #{Bot.emoticons[:crying_face]}
END
				}
			}
		}
		screens={
			:api=>{
				:access_granted=>{
					:text=>messages[:fr][:api][:access_granted],
					:disable_web_page_preview=>true,
					:jump_to=>"welcome/start"
				},
				:allow_user=>{
					:text=>messages[:fr][:api][:allow_user],
					:disable_web_page_preview=>true,
					:jump_to=>"home/welcome"
				},
				:ban_user=>{
					:text=>messages[:fr][:api][:ban_user],
					:disable_web_page_preview=>true,
					:jump_to=>"home/welcome"
				},
				:unblock_user=>{
					:text=>messages[:fr][:api][:unblock_user],
					:disable_web_page_preview=>true,
					:jump_to=>"home/welcome"
				},
				:block_candidate_reviews=>{
					:text=>messages[:fr][:api][:block_candidate_reviews],
					:disable_web_page_preview=>true,
					:jump_to=>"home/welcome"
				},
				:block_candidate_proposals=>{
					:text=>messages[:fr][:api][:block_candidate_proposals],
					:disable_web_page_preview=>true,
					:jump_to=>"home/welcome"
				}
			}
		}
		Bot.updateScreens(screens)
		Bot.updateMessages(messages)
	end

	def api_access_granted(msg,user,screen)
		puts "api_access_granted" if DEBUG
		@users.remove_from_waiting_list(user)
		@users.next_answer(user[:id],'answer')
		Democratech::LaPrimaireBot.mixpanel.track(user[:id],'api_grant_beta_access')
		return self.get_screen(screen,user,msg)
	end

	def api_allow_user(msg,user,screen)
		puts "api_allow_user" if DEBUG
		@users.update_settings(user[:id],{'blocked'=>{'not_allowed'=>false }})
		@users.next_answer(user[:id],'answer')
		Democratech::LaPrimaireBot.mixpanel.track(user[:id],'api_reallow_user')
		return self.get_screen(screen,user,msg)
	end

	def api_block_candidate_proposals(msg,user,screen)
		puts "api_block_candidate_proposals" if DEBUG
		@users.update_settings(user[:id],{'blocked'=>{'add_candidate'=>true }})
		@users.next_answer(user[:id],'answer')
		Democratech::LaPrimaireBot.mixpanel.track(user[:id],'api_block_add_candidate')
		return self.get_screen(screen,user,msg)
	end

	def api_block_candidate_reviews(msg,user,screen)
		puts "api_block_candidate_reviews" if DEBUG
		@users.update_settings(user[:id],{'blocked'=>{'reviews'=>true }})
		@users.next_answer(user[:id],'answer')
		Democratech::LaPrimaireBot.mixpanel.track(user[:id],'api_block_candidate_reviews')
		return self.get_screen(screen,user,msg)
	end

	def api_ban_user(msg,user,screen)
		puts "api_ban_user" if DEBUG
		@users.update_settings(user[:id],{'blocked'=>{'abuse'=>true }})
		@users.next_answer(user[:id],'answer')
		Democratech::LaPrimaireBot.mixpanel.track(user[:id],'api_ban_user')
		return self.get_screen(screen,user,msg)
	end

	def api_unblock_user(msg,user,screen)
		puts "api_unblock_user" if DEBUG
		@users.update_settings(user[:id],{'blocked'=>{
			'add_candidate'=>false,
			'abuse'=>false,
			'not_allowed'=>false,
			'review'=>false
		}})
		@users.next_answer(user[:id],'answer')
		Democratech::LaPrimaireBot.mixpanel.track(user[:id],'api_unblock_user')
		return self.get_screen(screen,user,msg)
	end
end

include Api
