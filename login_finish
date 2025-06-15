#!/opt/rbenv/shims/ruby

require 'net/http'
require 'json'
require 'uri'
require 'time'

class ClaudeLoginFinishOAuthOnly
  OAUTH_TOKEN_URL = 'https://console.anthropic.com/v1/oauth/token'
  CLIENT_ID = '9d1c250a-e61b-44d9-88ed-5944d1962f5e'
  REDIRECT_URI = 'https://console.anthropic.com/oauth/code/callback'
  STATE_FILE = File.expand_path('~/.claude/.claude_oauth_state.json')
  CREDENTIALS_PATH = File.expand_path('~/.claude/.credentials.json')

  def initialize(authorization_code)
    # Clean up the authorization code in case it has URL fragments
    @authorization_code = authorization_code.split('#').first.split('&').first
  end

  def complete_login
    unless verify_state
      puts "Error: Invalid or expired state. Please run ./login_start.rb again."
      return false
    end

    puts "Exchanging authorization code for tokens..."
    tokens = exchange_code_for_tokens
    
    if tokens
      puts "\nOAuth token exchange successful!"
      puts "Received scopes: #{tokens['scopes'].join(', ')}"
      
      # Save OAuth credentials without API key
      save_credentials(tokens)
      cleanup_state
      
      puts "\n=== IMPORTANT ==="
      puts "OAuth login successful, but API key creation was skipped."
      puts "Your OAuth credentials have been saved."
      puts "Claude Code will attempt to use OAuth tokens directly."
      puts "Token expires at: #{Time.at(tokens['expiresAt'] / 1000).strftime('%Y-%m-%d %H:%M:%S')}"
      puts "=================="
      
      true
    else
      puts "Login failed!"
      false
    end
  end

  private

  def verify_state
    return false unless File.exist?(STATE_FILE)
    
    begin
      state_data = JSON.parse(File.read(STATE_FILE))
      current_time = Time.now.to_i
      
      if current_time > state_data['expires_at']
        puts "Error: State has expired (older than 10 minutes)"
        return false
      end
      
      true
    rescue => e
      puts "Error reading state file: #{e.message}"
      false
    end
  end

  def exchange_code_for_tokens
    # Load state to get code_verifier
    state_data = JSON.parse(File.read(STATE_FILE))
    code_verifier = state_data['code_verifier']
    
    uri = URI(OAUTH_TOKEN_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'
    request['Accept'] = 'application/json, text/plain, */*'
    request['Accept-Language'] = 'en-US,en;q=0.9'
    request['Referer'] = 'https://claude.ai/'
    request['Origin'] = 'https://claude.ai'
    
    params = {
      'grant_type' => 'authorization_code',
      'client_id' => CLIENT_ID,
      'code' => @authorization_code,
      'redirect_uri' => REDIRECT_URI,
      'code_verifier' => code_verifier,
      'state' => state_data['state']
    }
    
    # Send as JSON
    request.body = JSON.generate(params)

    begin
      response = http.request(request)
      
      if response.code == '200'
        data = JSON.parse(response.body)
        
        {
          'accessToken' => data['access_token'],
          'refreshToken' => data['refresh_token'],
          'expiresAt' => (Time.now.to_i + data['expires_in']) * 1000,
          'scopes' => data['scope'] ? data['scope'].split(' ') : ['user:inference', 'user:profile'],
          'isMax' => true
        }
      else
        puts "Error response: #{response.code} - #{response.body}"
        nil
      end
    rescue => e
      puts "Error making token request: #{e.message}"
      nil
    end
  end

  def save_credentials(tokens)
    # Create credentials structure (without API key)
    credentials = {
      'claudeAiOauth' => tokens
    }
    
    # Ensure directory exists
    credentials_dir = File.dirname(CREDENTIALS_PATH)
    unless Dir.exist?(credentials_dir)
      require 'fileutils'
      FileUtils.mkdir_p(credentials_dir)
    end
    
    File.write(CREDENTIALS_PATH, JSON.pretty_generate(credentials))
  rescue => e
    puts "Error saving credentials: #{e.message}"
    false
  end

  def cleanup_state
    File.delete(STATE_FILE) if File.exist?(STATE_FILE)
  rescue => e
    puts "Warning: Could not clean up state file: #{e.message}"
  end
end

if __FILE__ == $0
  if ARGV.include?('--help') || ARGV.include?('-h') || ARGV.empty?
    puts "Usage: #{$0} <authorization_code>"
    puts "  Completes OAuth login WITHOUT creating API key"
    puts "  authorization_code: The code received from the OAuth callback"
    puts "  --help, -h        Show this help message"
    exit ARGV.empty? ? 1 : 0
  end
  
  authorization_code = ARGV[0]
  login = ClaudeLoginFinishOAuthOnly.new(authorization_code)
  
  success = login.complete_login
  exit(success ? 0 : 1)
end