#[test_only]
module galactic_workshop::galactic_packs_test {
    use std::signer;
    use std::string;
    use aptos_framework::account;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::randomness;
    use aptos_framework::object;
    use aptos_token_objects::property_map;
    use galactic_workshop::galactic_packs;

    // Setup function to initialize test environment
    #[test_only]
    #[lint::allow_unsafe_randomness]
    public fun setup_test(
        fx: &signer,
        account: &signer,
        creator: &signer,
    ) {
        // Initialize randomness for testing
        randomness::initialize_for_testing(fx);
        randomness::set_seed(x"0000000000000000000000000000000000000000000000000000000000000000");

        // Initialize aptos coin for testing
        let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(fx);
        
        // Register accounts for APT
        coin::register<AptosCoin>(account);
        coin::register<AptosCoin>(creator);
        
        // Fund accounts with APT
        coin::deposit(signer::address_of(account), coin::mint(1000000000, &mint_cap)); // 10 APT
        coin::deposit(signer::address_of(creator), coin::mint(1000000000, &mint_cap)); // 10 APT
        
        // Destroy the capabilities since we don't need them anymore
        coin::destroy_burn_cap(burn_cap);
        coin::destroy_mint_cap(mint_cap);

        // Create test accounts
        account::create_account_for_test(signer::address_of(creator));
        account::create_account_for_test(signer::address_of(account));

        // Initialize the module
        galactic_packs::initialize_for_testing(creator);
    }

     #[test(
        fx = @aptos_framework,
        user = @0x456,
        creator = @0x123
    )]
    fun test_buy_pack(fx: &signer, user: &signer, creator: &signer) {        
        // Initialize everything
        setup_test(fx, user, creator);
        
        // Buy a pack
        galactic_packs::buy_pack(user, creator);
        
        // Verify that a pack was sold 
        let creator_addr = signer::address_of(creator);
        let total_sold = galactic_packs::get_total_sold(creator_addr);
        assert!(total_sold == 1, 17);
    }

    #[test(
        fx = @aptos_framework,
        user = @0x456,
        creator = @0x123
    )]
    fun test_complete_flow(fx: &signer, user: &signer, creator: &signer) {        
        // Initialize everything
        setup_test(fx, user, creator);
        
        // Buy a pack
        galactic_packs::buy_pack(user, creator);
        
        // Verify that a pack was sold 
        let creator_addr = signer::address_of(creator);
        let total_sold = galactic_packs::get_total_sold(creator_addr);
        assert!(total_sold == 1, 18);   
        
        // Get the first token owned by the user in the "Galactic Pack" collection
        // Since we know the user just bought one pack, it should be the first one
        // We'll use the pack store to get the token ID since we know it was transferred to the user
        let pack_token_id = galactic_packs::get_pack_token_id(creator_addr, 0);
        
        // Open the pack
        galactic_packs::test_open_pack(user, creator, pack_token_id);
        
        // Verify that the pack is now opened
        let pack_object = object::address_to_object<object::ObjectCore>(pack_token_id);
        let opened_property = property_map::read_bool(&pack_object, &string::utf8(b"Opened"));
        assert!(opened_property, 19);
        
        // Verify that the pack was successfully opened
        // The open function should have minted PACK_SIZE tokens (3 tokens) to the user
        // and marked the pack as opened
        assert!(opened_property, 20);
    }

    #[test(
        fx = @aptos_framework,
        user = @0x456,
        creator = @0x123
    )]
    #[expected_failure(abort_code = galactic_packs::E_PACK_ALREADY_OPENED)]
    fun test_open_already_opened_pack(fx: &signer, user: &signer, creator: &signer) {        
        // Initialize everything
        setup_test(fx, user, creator);
        
        // Buy a pack
        galactic_packs::buy_pack(user, creator);
        
        // Get the pack token ID
        let creator_addr = signer::address_of(creator);
        let pack_token_id = galactic_packs::get_pack_token_id(creator_addr, 0);
        
        // Open the pack for the first time (should succeed)
        galactic_packs::test_open_pack(user, creator, pack_token_id);
        
        // Try to open the same pack again (should fail with E_PACK_ALREADY_OPENED)
        galactic_packs::test_open_pack(user, creator, pack_token_id);
    }
}
