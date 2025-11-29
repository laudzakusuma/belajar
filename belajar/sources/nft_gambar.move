module belajar::nft_gambar {
    use std::string::{Self, String};
    use sui::url::{Self, Url};
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::package;
    use sui::display;

    public struct MyImageNFT has key, store {
        id: UID,
        name: String,
        description: String,
        image_url: Url,
    }

    public struct NFT_GAMBAR has drop {}
    public struct MintEvent has copy, drop {
        object_id: ID,
        creator: address,
        name: String,
    }

    fun init(otw: NFT_GAMBAR, ctx: &mut TxContext) {
        let publisher = package::claim(otw, ctx);

        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"link"),
            string::utf8(b"image_url"),
            string::utf8(b"description"),
            string::utf8(b"project_url"),
            string::utf8(b"creator"),
        ];

        let values = vector[
            string::utf8(b"{name}"),
            string::utf8(b"https://sui.io"),
            string::utf8(b"{image_url}"),
            string::utf8(b"{description}"),
            string::utf8(b"https://belajar-sui.com"),
            string::utf8(b"Tim Belajar Sui")
        ];

        let mut display = display::new_with_fields<MyImageNFT>(
            &publisher, keys, values, ctx
        );

        display::update_version(&mut display);

        transfer::public_share_object(display);
        transfer::public_transfer(publisher, tx_context::sender(ctx));
    }

    public entry fun mint_to_sender(
        name: vector<u8>,
        description: vector<u8>,
        url_bytes: vector<u8>,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);

        let nft = MyImageNFT {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            image_url: url::new_unsafe_from_bytes(url_bytes),
        };

        event::emit(MintEvent {
            object_id: object::id(&nft),
            creator: sender,
            name: nft.name,
        });

        transfer::public_transfer(nft, sender);
    }
}