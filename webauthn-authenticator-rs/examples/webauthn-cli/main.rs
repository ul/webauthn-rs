use clap::Parser;
use webauthn_authenticator_rs::prelude::Url;
use webauthn_authenticator_rs::AuthenticatorBackend;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    #[arg(short, long, required = true)]
    origin: Url,
    #[arg(short, long, required = true)]
    auth_options_json: String,
    #[arg(short, long, default_value_t = 60_000)]
    timeout: u32,
}

fn main() {
    let args = Args::parse();
    let options = serde_json::from_str(&args.auth_options_json).unwrap();
    eprintln!("Touch the key to authenticate");
    let response = webauthn_authenticator_rs::u2fhid::U2FHid::default()
        .perform_auth(args.origin, options, args.timeout)
        .unwrap();
    println!("{}", serde_json::to_string(&response).unwrap());
}
