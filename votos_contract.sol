pragma solidity ^0.8.0;

contract VotacaoComComprometimento {
    struct Eleitor {
        bytes32 comprometimento;
        bool votou;
        bool comprometimentoRevelado;
    }

    mapping(address => Eleitor) public eleitores;
    string[] public candidatos;
    mapping(uint => uint) public votos;
    uint public fimDoComprometimento;
    uint public fimDaVotacao;

    constructor(string[] memory nomesCandidatos, uint duracaoDoComprometimento, uint duracaoDaVotacao) {
        candidatos = nomesCandidatos;
        fimDoComprometimento = block.timestamp + duracaoDoComprometimento;
        fimDaVotacao = fimDoComprometimento + duracaoDaVotacao;
    }

    function comprometerVoto(bytes32 hash) public {
        require(block.timestamp <= fimDoComprometimento, "Periodo de comprometimento encerrado.");
        require(!eleitores[msg.sender].votou, "Eleitor ja votou.");

        eleitores[msg.sender].comprometimento = hash;
        eleitores[msg.sender].votou = true;
    }

    function revelarVoto(uint indiceCandidato, string memory segredo) public {
        require(block.timestamp > fimDoComprometimento && block.timestamp <= fimDaVotacao, "Nao eh possivel revelar o voto agora.");
        require(eleitores[msg.sender].votou, "Eleitor nao votou.");
        require(!eleitores[msg.sender].comprometimentoRevelado, "Voto ja revelado.");

        // Geração do hash a partir do índice do candidato e segredo
        string memory indiceStr = toString(indiceCandidato);
        string memory votoCombinado = string(abi.encodePacked(indiceStr, segredo));
        bytes32 hash = keccak256(abi.encodePacked(votoCombinado));
        require(hash == eleitores[msg.sender].comprometimento, "O comprometimento nao corresponde ao voto revelado.");

        eleitores[msg.sender].comprometimentoRevelado = true;
        votos[indiceCandidato]++;
    }

    function totalVotos(uint indiceCandidato) public view returns (uint) {
        return votos[indiceCandidato];
    }

    // Função auxiliar para converter uint para string
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        bytes memory buffer = new bytes(64);
        uint256 length = 0;
        while (value != 0) {
            length++;
            buffer[64 - length] = bytes1(uint8(48 + value % 10));
            value /= 10;
        }
        bytes memory stringBuffer = new bytes(length);
        for (uint256 i = 0; i < length; i++) {
            stringBuffer[i] = buffer[64 - length + i];
        }
        return string(stringBuffer);
    }
}
