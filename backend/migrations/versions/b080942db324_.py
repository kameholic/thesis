"""empty message

Revision ID: b080942db324
Revises: 3859c6267e71
Create Date: 2019-12-09 03:22:19.055280

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = 'b080942db324'
down_revision = '3859c6267e71'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.alter_column('diet_day', 'breakfast_portion',
               existing_type=sa.FLOAT(),
               type_=sa.String(length=128),
               existing_nullable=True)
    op.alter_column('diet_day', 'dinner_portion',
               existing_type=sa.FLOAT(),
               type_=sa.String(length=128),
               existing_nullable=True)
    op.alter_column('diet_day', 'lunch_portion',
               existing_type=sa.FLOAT(),
               type_=sa.String(length=128),
               existing_nullable=True)
    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    op.alter_column('diet_day', 'lunch_portion',
               existing_type=sa.String(length=128),
               type_=sa.FLOAT(),
               existing_nullable=True)
    op.alter_column('diet_day', 'dinner_portion',
               existing_type=sa.String(length=128),
               type_=sa.FLOAT(),
               existing_nullable=True)
    op.alter_column('diet_day', 'breakfast_portion',
               existing_type=sa.String(length=128),
               type_=sa.FLOAT(),
               existing_nullable=True)
    # ### end Alembic commands ###
