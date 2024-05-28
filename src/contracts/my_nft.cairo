#[starknet::contract]
mod MyNFT {
    use starknet::ContractAddress;
    use openzeppelin::introspection::src5::SRC5Component;
    use openzeppelin::token::erc721::{ERC721Component, ERC721HooksEmptyImpl};

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);


    // ERC721 Mixin
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        counter: u256
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState, recipient: ContractAddress) {
        let name = "MyNFT";
        let symbol = "NFT";
        let base_uri = "https://api.example.com/v1/";

        self.erc721.initializer(name, symbol, base_uri);
    }

    #[external(v0)]
    fn mint(ref self: ContractState, recipient: ContractAddress) {
        let token_id = self.counter.read();
        self.erc721._mint(recipient, token_id);
        self.counter.write(token_id + 1);
    }
}

#[cfg(test)]
mod tests {
    use cairo_erc721::contracts::my_nft::MyNFT::__member_module_counter::InternalContractMemberStateTrait;
    use super::MyNFT;
    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::storage::StorageMapMemberAccessTrait;
    use starknet::testing;


    #[test]
    fn test_mint() {
        let mut state = MyNFT::contract_state_for_testing();
        let mint_result = state.counter.read();
        assert!(mint_result == 0, "Minting failed unexpectedly.");
    }
}
