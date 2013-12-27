# SPARC64(TM) VIIIfx/IXfx �����v���t�@�C����̓X�N���v�g

## �T�v

Fujitsu PRIMEHPC FX10�⋞�R���s���[�^�ɂ�����A�����v���t�@�C���̏o�͂���csv�t�@�C������͂��A���ʂ�W���o�͂ɏo�͂���X�N���v�g�B

- rprof.rb ��̓X�N���v�g
- events.csv �C�x���g�e�[�u��

## �g����

�C�x���g�e�[�u���t�@�C��(events.csv)�y�щ�̓X�N���v�grprof.rb�Ɠ����Ƃ����csv�t�@�C����p�ӂ��A�ȉ��̂悤�ɗ��p���܂��B

  $ ruby rprof.rb output_prof*.csv

�o�͌��ʂ́A�v���Z�X�y�уX���b�h�P�ʁB�ϑ��͈�(start/end_collection�ŋ��܂ꂽ�ꏊ)�͑S�Ă܂Ƃ߂ďo�͂��܂��B�V���O���X���b�h�W���u�Aflat-MPI�Ahybrid�ɑΉ����Ă���͂��ŁAFX10/�����������ʂ���͂��ł�������ɂ��Ă͕ۏ؂��܂���B

## ���ӎ���

- �����v���t�@�C���̗��p���@������Ă���Ɛ����������擾�ł��܂���B�����v���t�@�C���̎g������A�W���u�̓������@�ɂ��ẮA�e�T�C�g�̃}�j���A�����Q�Ƃ��Ă��������B�X�N���v�g��҂ւ̖₢���킹�͂��������������B
- �{�X�N���v�g�̏o�͌��ʂ̐��m���ɂ��Ă͕ۏ؂��܂���B�o�O�̕񍐂͊��}�������܂����A�T�|�[�g�̕ۏ؂͂��܂���B
- �{�X�N���v�g�ɂ��ĕx�m�ʊ�����Ђ◝���w�������͖��֌W�ł��B�{�X�N���v�g�ɂ��ĕx�m�ʊ�����Ђ◝���w�������ւ̖₢���킹�͂��������������B
- �{�X�N���v�g�́A�����v���t�@�C���̎d�l�ύX�ɂ���Ďg���Ȃ��Ȃ�\��������܂��B

## ���C�Z���X

�{�X�N���v�g�͏C��BSD���C�Z���X(�����BSD���C�Z���X)�ɂĒ񋟂������܂��B

## �o�͓��e�̐���

### Performance Information
�S�̓I�Ȑ��\��\������Z�N�V�����B

- ELAPSED �o�ߎ��ԁB�P�ʂ͕b�B
- MFLOPS ���Z���\�B�P�ʂ�MFLOPS�B
- PEAK(%) �s�[�N���\��B
- MIPS ���Z���B�P�ʂ�MIPS(�S���C���X�g���N�V�������b)

### SIMD Information
���������_���Z�ƁA����SIMD�̐��\��\������Z�N�V�����B

- SIMD(%)SIMD�����ꂽ���������_���Z(��Z/�����Z)�̊����B
- FLOAT(%) SIMD������Ă��Ȃ����������_���Z(��Z/�����Z)�̊����B
- SIMD-FMA(%) SIMD�����ꂽ�Ϙa���Z�̊����B
- FMA(%) SIMD������Ă��Ȃ��Ϙa���Z�̊����B

### Cache Information
�L���b�V���~�X�֘A

- L1DMISS(%) L1�f�[�^�L���b�V���~�X��
- L2MISS(%) L2�L���b�V���~�X��
- MTLBMISS(%) �f�[�^���C��TLB�~�X��
- UTLBMISS(%) �}�C�N���f�[�^TLB�~�X��

### Wait Information (Instruction)
�҂����(���ߊ֘A)

- BARRIER(%) �X���b�h�����҂�����(MPI�̃o���A�ł͂Ȃ�)
- INTWAIT(%) �������Z�̈ˑ��֌W�ɂ��҂�����
- FLWAIT(%) ���������_���Z�̈ˑ��֌W�ɂ��҂�����
- BRWAIT(%) ���򖽗߂ɂ��҂�����
- INSTFETCH(%) ���߃t�F�b�`�҂�����

### Wait Information (Memory/Cache)
�҂����(������/�L���b�V���֘A)

- IMEMWAIT(%) �����̃���������̃��[�h�҂�
- ICACHEWAIT(%) �����̃L���b�V������̃��[�h�҂�
- FLMEMWAIT(%) �����̃���������̃��[�h�҂�
- FLCACHEWAIT(%) �����̃L���b�V������̃��[�h�҂�

### Commit Information 
���߃R�~�b�g���

- 0ENDOP(%) ���߂�������s���Ȃ������T�C�N������
- 1ENDOP(%) 1�T�C�N���ň���߂𔭍s��������
- 2/3ENDOP(%) 1�T�C�N���œ�Ȃ����O�̖��߂𓯎��ɔ��s��������
- GPRWAIT(%) GPR�������݃|�[�g�����܂��Ă��邽��4���ߓ������s�ł��Ȃ��������� (�������W�X�^��2�A�b�v�f�[�g��)
- 4ENDOP(%) 1�T�C�N����4�̖��߂𓯎��ɔ��s��������


### Other Information 
���̑�

- IPC �T�C�N��������̕��ϖ��ߐ�(Instruction Per Cycle)

###Measured Events
�擾�����C�x���g���X�g�B�ڍׂɂ��Ă�[SPARC64(TM) VIIIfx Extensions (PDF)](http://img.jp.fujitsu.com/downloads/jp/jhpc/sparc64viiifx-extensionsj.pdf)���Q�Ƃ��邱�ƁB
