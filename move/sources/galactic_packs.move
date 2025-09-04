
module galactic_workshop::galactic_packs {
    use std::signer;
    use std::string::{Self, String};
    use std::vector;
    use std::bcs;
    use aptos_framework::coin;
    use aptos_framework::object;
    use aptos_token_objects::aptos_token;
    use aptos_token_objects::property_map;

    // Error codes
    const E_NOT_AUTHORIZED: u64 = 1;
    const E_PACK_ALREADY_OPENED: u64 = 2;
    const E_NO_PACKS_AVAILABLE: u64 = 3;

    // Constants
    const PACK_PRICE: u64 = 10000000; // 0.1 APT in octas
    const MAX_PACKS: u64 = 100;
    const PACK_SIZE: u64 = 3; // 3 NFTs per pack

    // Collection types
    const COLLECTION_GALACTIC_PACK: u64 = 0;
    const COLLECTION_ALIEN: u64 = 1;    
    const COLLECTION_PREDATOR: u64 = 2;
    const COLLECTION_YODA: u64 = 3;

    // ===== CONSTANTS =====
    // Collection names
    const COLLECTION_NAMES: vector<vector<u8>> = vector[
        b"Galactic Pack",
        b"Alien",
        b"Predator",
        b"Yoda"
    ];
    
    // Collection URIs on IPFS
    const COLLECTION_URIS: vector<vector<u8>> = vector[
        b"ipfs://bafybeicwqydziv5v5mhrplwu7ejfqyf36vugqgbkhju6mbbl6kttiiq33y",
        b"ipfs://bafybeidkl6xkucmemtszbc22yx4l2u27msicv3rmdzevxafb3qh3c6kvwi", 
        b"ipfs://bafybeifk2osoj6qidw6vbecl3t4kg4mqneq5yesywx6bybwjyg35zsyxeu",
        b"ipfs://bafybeigdynpadvw7mra7gn6wph24ewxwtdhknhdpjes3on2sfdxfeyajmy"
    ];

    // ===== STRUCTURES =====
    // PackStore: Global storage for managing pack sales and tracking
    // 
    // This struct stores:
    // - packs: Vector of addresses where packs have been minted
    // - total_sold: Total number of packs sold to date
    struct PackStore has key {
        packs: vector<address>,
        total_sold: u64,
    }
    
    // ===== INITIALIZATION =====
    // Initializes the Galactic Packs module
    // 
    // This function is called once when the module is deployed and:
    // - Creates all NFT collections (Galactic Pack, Alien, Predator, Yoda)
    // - Mints the initial galactic pack for the creator
    // 
    // Parameters:
    // - creator: &signer - The account that deploys this module
    fun init_module(creator: &signer) acquires PackStore {
 // Create collections for each type using a loop
        create_collections(creator);
        // Mint galactic pack
        mint_pack(creator);
    }

   // ===== FUNCTIONS =====
    // Creates all NFT collections by iterating through the collection types
    // 
    // Parameters:
    // - creator: &signer - The account creating all collections
    inline fun create_collections(creator: &signer) {
        let i = 0;
        let total_collections = vector::length(&COLLECTION_NAMES);
        while (i < total_collections) {
            create_collection(creator, i);
            i = i + 1;
        };
    }

    // Creates a single NFT collection based on the collection type
    // 
    // Parameters:
    // - creator: &signer - The account creating the collection
    // - collection_type: u64 - Index of the collection (0=Galactic Pack, 1=Alien, 2=Predator, 3=Yoda)
    inline fun create_collection(creator: &signer, collection_type: u64) {
        // Get collection-specific name and URI from get_collection_info
        let (collection_name, image_uri) = get_collection_info(collection_type);
        
        let description = string::utf8(b"Collection of Galactic Characters");
        
        // https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/framework/aptos-token-objects/sources/aptos_token.move
        // Create collection using aptos_token_objects
        aptos_token::create_collection(
            creator,
            description,
            1000000, 
            collection_name,
            image_uri,
            true, true, true, true, true, true, true, false, false,
            5, 100 
        );
    }
 
    // Retrieves collection information by collection type index
    // 
    // Parameters:
    // - collection_type: u64 - Index of the collection (0=Galactic Pack, 1=Alien, 2=Predator, 3=Yoda)
    // 
    // Returns: (String, String) - Tuple containing (collection_name, image_uri)
    // 
    // Aborts if:
    // - collection_type is out of bounds of COLLECTION_NAMES vector
    // 
    // Example:
    // - collection_type = 1 returns ("Alien", "ipfs://...")
    public fun get_collection_info(collection_type: u64): (String, String) {
        (string::utf8(*vector::borrow(&COLLECTION_NAMES, collection_type)), 
         string::utf8(*vector::borrow(&COLLECTION_URIS, collection_type)))
    }

    // Mints the initial collection of MAX_PACKS (100) galactic packs for the creator
    // 
    // Parameters:
    // - creator: &signer - The account that will own all the packs
    // 
    // This function:
    // - Creates PackStore if it doesn't exist
    // - Mints MAX_PACKS number of packs with unique pack numbers
    // - Each pack has properties: "Pack Number" and "Opened" (initially false)
    // - Stores all pack token addresses in PackStore.packs vector
    inline fun mint_pack(creator: &signer) {
        let creator_addr = signer::address_of(creator);    

        move_to(creator, PackStore {
            packs: vector::empty(),
            total_sold: 0,
        });

        let pack_store = borrow_global_mut<PackStore>(creator_addr);
        
        let (collection_name, image_uri) = get_collection_info(COLLECTION_GALACTIC_PACK);
        let i = 1;
        while (i <= MAX_PACKS) {
            let property_keys = vector::empty<string::String>();
            let property_types = vector::empty<string::String>();
            let property_values = vector::empty<vector<u8>>();

            // Add pack number as property
            vector::push_back(&mut property_keys, string::utf8(b"Pack Number"));
            vector::push_back(&mut property_types, string::utf8(b"u64"));
            vector::push_back(&mut property_values, bcs::to_bytes(&i));

            // Add opened property as false initially
            vector::push_back(&mut property_keys, string::utf8(b"Opened"));
            vector::push_back(&mut property_types, string::utf8(b"bool"));
            vector::push_back(&mut property_values, bcs::to_bytes(&false));

            let token_id = aptos_token::mint_token_object(
                creator, //creator
                collection_name, //collection name
                string::utf8(b"A mysterious pack containing galactic characters"), //description
                collection_name, //name
                image_uri, //metadata uri
                property_keys, //property keys
                property_types, //property types    
                property_values, //property values
            );
            
            //Get the token id as an address
            let token_id_address = object::object_address(&token_id);
            // Store the pack
            vector::push_back(&mut pack_store.packs, token_id_address);
            
            i = i + 1;
        };
    }

    // View function to get total packs sold by a creator
    // 
    // Parameters:
    // - creator_addr: address - The address of the pack creator
    // 
    // Returns: u64 - Total number of packs sold (0 if creator has no PackStore)
    // 
    // This function is marked as #[view] for easy querying from the frontend
    #[view]
    public fun get_total_sold(creator_addr: address): u64 acquires PackStore {
        if (exists<PackStore>(creator_addr)) {
            // borrow_global returns an immutable reference (&PackStore)
            // Accessing a primitive field (u64) automatically copies the value
            borrow_global<PackStore>(creator_addr).total_sold
        } else {
            0
        }
    }

    // View function to get pack token ID by index from a creator's collection
    // 
    // Parameters:
    // - creator_addr: address - The address of the pack creator
    // - index: u64 - Index of the pack in the creator's collection (0-based)
    // 
    // Returns: address - The token ID address of the pack, or @0x0 if creator has no PackStore
    // 
    // This function is marked as #[view] for easy querying from the frontend
    #[view]
    public fun get_pack_token_id(creator_addr: address, index: u64): address acquires PackStore {
        if (exists<PackStore>(creator_addr)) {
            let pack_store = borrow_global<PackStore>(creator_addr);
            // vector::borrow returns &address, so we need dereference (*) to get the value
            *vector::borrow(&pack_store.packs, index)
        } else {
            @0x0
        }
    }

    // Allows a user to purchase a galactic pack from the creator
    // 
    // Parameters:
    // - user: &signer - The account buying the pack
    // - creator: &signer - The account selling the pack (must sign for transfer)
    // 
    // Returns: None
    // 
    // This function:
    // - Checks if packs are available for purchase
    // - Transfers PACK_PRICE (0.1 APT) from user to creator
    // - Transfers the pack NFT from creator to user
    // - Increments total_sold counter
    // 
    // Aborts if:
    // - Creator doesn't have a PackStore
    // - No packs available (total_sold >= MAX_PACKS)
    // - User doesn't have enough APT
    // - Transfer fails
    public entry fun buy_pack(
        user: &signer, 
        creator: &signer, 
    ) acquires PackStore {
        let user_addr = signer::address_of(user);
        let creator_addr = signer::address_of(creator);
        
        // Check if there are packs available
        assert!(exists<PackStore>(creator_addr), E_NOT_AUTHORIZED);
        let pack_store = borrow_global_mut<PackStore>(creator_addr);
        assert!(pack_store.total_sold < MAX_PACKS, E_NO_PACKS_AVAILABLE); 

        // Transfer payment from user to creator
        // https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/framework/aptos-token-objects/doc/property_map.md#0x4_property_map
        let user_coin = coin::withdraw<aptos_framework::aptos_coin::AptosCoin>(user, PACK_PRICE);
        coin::deposit(creator_addr, user_coin);

        // Get the pack using total_sold as index
        let pack_token_id = vector::borrow(&pack_store.packs, pack_store.total_sold); 
        let pack_object = object::address_to_object<object::ObjectCore>(*pack_token_id);

        // Increment total sold
        pack_store.total_sold = pack_store.total_sold + 1;

        // Transfer the pack object from the creator to the user.
        // This requires the creator to sign the transaction.
        object::transfer(creator, pack_object, user_addr);
    }

    // Allows a user to open a galactic pack and receive random NFTs
    // 
    // Parameters:
    // - user: &signer - The account opening the pack (must own the pack)
    // - creator: &signer - The pack creator (must sign for property updates)
    // - pack_token_id: address - The address of the pack NFT to open
    // 
    // Returns: None
    // 
    // This function:
    // - Verifies the user owns the pack
    // - Checks if the pack is already opened
    // - Marks the pack as opened
    // - Mints PACK_SIZE (3) random NFTs and transfers them to the user
    // 
    // Aborts if:
    // - User doesn't own the pack
    // - Pack is already opened
    // - Property update fails
    // - NFT minting fails
    // 
    // Requires #[randomness] attribute for NFT rarity generation
    #[randomness]
    entry fun open_pack(
        user: &signer,
        creator: &signer,
        pack_token_id: address
    ) {
        open_pack_internal(user, creator, pack_token_id);
    }

    // Internal function that handles the pack opening logic
    // 
    // Parameters:
    // - user: &signer - The account opening the pack
    // - creator: &signer - The pack creator
    // - pack_token_id: address - The address of the pack NFT to open
    // 
    // Returns: None
    // 
    // This function:
    // - Validates pack ownership
    // - Checks if pack is already opened
    // - Updates pack "Opened" property to true
    // - Triggers NFT minting and transfer
    // 
    // Aborts if:
    // - User doesn't own the pack
    // - Pack is already opened
    // - Property update fails
    fun open_pack_internal(
        user: &signer,
        creator: &signer,
        pack_token_id: address
    ) {
        let user_addr = signer::address_of(user);
    
        let pack_object = object::address_to_object<object::ObjectCore>(pack_token_id);
        // Check if the user has the pack
        // https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/framework/aptos-framework/doc/object.md#0x1_object_is_owner
        assert!(object::is_owner(pack_object, user_addr), E_NOT_AUTHORIZED); 

        // Check if the pack is already opened
        let opened_property = property_map::read_bool(&pack_object, &string::utf8(b"Opened"));
        assert!(!opened_property, E_PACK_ALREADY_OPENED);
        
        // Update opened property to true
        // https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/framework/aptos-token-objects/doc/aptos_token.md#0x4_aptos_token_update_property
        aptos_token::update_property(
            creator,
            pack_object,
            string::utf8(b"Opened"),
            string::utf8(b"bool"),
            bcs::to_bytes(&true),
        );
        
        // Mint PACK_SIZE tokens of different types and transfer to user
        mint_and_transfer_tokens(creator, user_addr);
    }
    
    // Mints PACK_SIZE (3) random NFTs and transfers them to the user
    // 
    // Parameters:
    // - creator: &signer - The account minting the NFTs
    // - user_addr: address - The address receiving the NFTs
    // 
    // Returns: None
    // 
    // This function:
    // - Mints one NFT from each collection (Alien, Predator, Yoda)
    // - Each NFT gets a random rarity level
    // - Transfers all NFTs directly to the user
    // 
    // Aborts if:
    // - NFT minting fails
    // - Transfer fails
    // - Randomness service unavailable
    inline fun mint_and_transfer_tokens(creator: &signer, user_addr: address) {
        let i = 0;
        while (i < PACK_SIZE) {
            // Set collection type based on iteration, starting from 1 (0 is Galactic Pack)
            let collection_type = i + 1;
            
            // Get collection info
            let (collection_name, collection_uri) = get_collection_info(collection_type);
            
            // Get random rarity for this token
            let rarity = get_random_rarity();

            // Create properties for the token
            let property_keys = vector::empty<string::String>();
            let property_types = vector::empty<string::String>();
            let property_values = vector::empty<vector<u8>>();            
       
            // Add rarity property
            vector::push_back(&mut property_keys, string::utf8(b"Rarity"));
            vector::push_back(&mut property_types, string::utf8(b"0x1::string::String"));
            vector::push_back(&mut property_values, bcs::to_bytes(&rarity));                         
            
            // Mint the token
            let token_id = aptos_token::mint_token_object(
                creator,
                collection_name,
                string::utf8(b"An epic warrior from the depths of space"),
                collection_name,
                collection_uri,
                property_keys,
                property_types,
                property_values,
            );
            
            // Transfer the token to the user
            object::transfer(creator, token_id, user_addr);
            
            i = i + 1;
        };
    }

    // Generates a random rarity level for NFT packs using Aptos randomness
    // 
    // Parameters: None
    // 
    // Returns: string::String - The rarity level as a string
    // 
    // Rarity distribution:
    // - Common: 30% chance
    // - Uncommon: 25% chance  
    // - Rare: 20% chance
    // - Epic: 12% chance
    // - Legendary: 8% chance
    // - Mythic: 5% chance
    // 
    // Aborts if:
    // - Aptos randomness service is unavailable
    fun get_random_rarity(): string::String {
        // Balanced rarity system with good chances for rare items:
        // Common (30%), Uncommon (25%), Rare (20%), Epic (12%), Legendary (8%), Mythic (5%)
        let random_value = aptos_framework::randomness::u64_range(0, 100);
        
        if (random_value < 30) return string::utf8(b"Common");
        if (random_value < 55) return string::utf8(b"Uncommon");
        if (random_value < 75) return string::utf8(b"Rare");
        if (random_value < 87) return string::utf8(b"Epic");
        if (random_value < 95) return string::utf8(b"Legendary");
        string::utf8(b"Mythic")
    }



    // ===== TEST FUNCTIONS =====

    // Test-only function for opening packs (easier to use in tests)
    #[test_only]
    #[lint::allow_unsafe_randomness]
    public fun test_open_pack(
        user: &signer,
        creator: &signer,
        pack_token_id: address
    ) {
        open_pack_internal(user, creator, pack_token_id);
    }

    // Public function for testing initialization
    #[test_only]
    public fun initialize_for_testing(creator: &signer) acquires PackStore {
        // Create collections for each type using a loop
        create_collections(creator);
        // Mint galactic pack
        mint_pack(creator);
    }

}
